"""Application-level authentication and account-recovery business logic."""

from datetime import timedelta

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException, status
from pymongo.errors import DuplicateKeyError
from starlette.requests import Request
import jwt

from app.auth.email_service import EmailService
from app.auth.otp_service import OtpService
from app.auth.repository import AuthRepository
from app.auth.schemas import AuthResponse, LoginRequest, RegisterRequest, TokenPairResponse, UserResponse
from app.core.config import get_settings
from app.core.security import (
    constant_time_equals,
    create_access_token,
    create_refresh_token,
    create_uuid_token,
    decode_token,
    hash_password,
    hash_refresh_token,
    utc_now,
    verify_password,
)


class AuthService:
    """Coordinate authentication workflows across MongoDB, Redis, and email."""

    def __init__(self, repository: AuthRepository, otp_service: OtpService, email_service: EmailService) -> None:
        """Initialize the service with its persistence and delivery collaborators."""
        self.repository = repository
        self.otp_service = otp_service
        self.email_service = email_service
        self.settings = get_settings()

    def _to_user_response(self, user: dict) -> UserResponse:
        """Convert a MongoDB user document into the public API representation."""
        return UserResponse(
            id=str(user["_id"]),
            username=user["username"],
            email=user["email"],
            role=user["role"],
            is_email_verified=user.get("is_email_verified", False),
            created_at=user["created_at"],
            updated_at=user["updated_at"],
        )

    def _build_token_pair(self, access_token: str, refresh_token: str) -> TokenPairResponse:
        """Build the token response with configured expiry durations."""
        return TokenPairResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            access_token_expires_in=self.settings.access_token_exp_minutes * 60,
            refresh_token_expires_in=self.settings.refresh_token_exp_days * 24 * 60 * 60,
        )

    def _build_session_context(self, request: Request) -> dict:
        """Extract non-sensitive device and network metadata for a session."""
        return {
            "device_name": request.headers.get("x-device-name"),
            "user_agent": request.headers.get("user-agent"),
            "ip_address": request.client.host if request.client else None,
        }

    def _create_auth_response(self, user: dict, request: Request) -> AuthResponse:
        """Create a refresh session and return access and refresh tokens."""
        now = utc_now()
        session_id = ObjectId()
        refresh_jti = create_uuid_token()
        refresh_token = create_refresh_token(str(user["_id"]), str(session_id), refresh_jti)
        access_token = create_access_token(str(user["_id"]))
        context = self._build_session_context(request)
        self.repository.create_session(
            {
                "_id": session_id,
                "user_id": user["_id"],
                "refresh_token_hash": hash_refresh_token(refresh_token),
                "refresh_jti": refresh_jti,
                "device_name": context["device_name"],
                "user_agent": context["user_agent"],
                "ip_address": context["ip_address"],
                "created_at": now,
                "last_used_at": now,
                "expires_at": now + timedelta(days=self.settings.refresh_token_exp_days),
                "revoked_at": None,
            }
        )
        self.repository.update_user_last_login(user["_id"], now)
        user["last_login_at"] = now
        return AuthResponse(
            user=self._to_user_response(user),
            tokens=self._build_token_pair(access_token, refresh_token),
        )

    def _send_otp(self, purpose: str, email: str, data: dict, send_email) -> None:
        """Persist an OTP challenge and remove it if email delivery fails."""
        otp = self.otp_service.create(purpose, email, data)
        try:
            send_email(otp)
        except Exception as exc:
            self.otp_service.delete(purpose, email)
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Unable to send verification email",
            ) from exc

    def get_current_user(self, user_id: ObjectId) -> UserResponse:
        """Load an active user for a protected profile request."""
        user = self.repository.get_user_by_id(user_id)
        if user is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
        if not user.get("is_active", True):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
        return self._to_user_response(user)

    def request_registration(self, payload: RegisterRequest) -> dict[str, str]:
        """Store a pending registration in Redis and send its verification OTP."""
        email = str(payload.email).lower()
        if self.repository.get_user_by_email(email) is None:
            data = {
                "username": payload.username.strip(),
                "email": email,
                "password_hash": hash_password(payload.password),
            }
            self._send_otp(
                "register",
                email,
                data,
                lambda otp: self.email_service.send_verification_otp(email, data["username"], otp),
            )
        return {"detail": "If the email can be registered, a verification code has been sent."}

    def resend_registration_otp(self, email: str) -> dict[str, str]:
        """Resend an active registration OTP without exposing account state."""
        email = email.lower()
        if self.repository.get_user_by_email(email) is not None:
            return {"detail": "If the email can be registered, a verification code has been sent."}
        pending = self.otp_service.get("register", email)
        if pending is not None:
            self._send_otp(
                "register",
                email,
                {key: pending[key] for key in ("username", "email", "password_hash")},
                lambda otp: self.email_service.send_verification_otp(email, pending["username"], otp),
            )
        return {"detail": "If the email can be registered, a verification code has been sent."}

    def verify_registration(self, email: str, otp: str) -> dict[str, str]:
        """Verify a registration OTP and create the verified MongoDB user."""

        email = email.lower()
        pending = self.otp_service.verify("register", email, otp)

        now = utc_now()

        admin_email = self.settings.first_admin_email.strip().lower()

        role = "admin" if email == admin_email else "user"

        user_doc = {
            "username": pending["username"],
            "email": email,
            "password_hash": pending["password_hash"],
            "role": role,
            "is_active": True,
            "is_email_verified": True,
            "email_verified_at": now,
            "last_login_at": None,
            "created_at": now,
            "updated_at": now,
        }

        try:
            self.repository.create_user(user_doc)
        except DuplicateKeyError as exc:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Email already exists",
            ) from exc

        return {"detail": "Email verified successfully. Please log in."}


    def login(self, payload: LoginRequest, request: Request) -> AuthResponse:
        """Authenticate a verified, active user and create a login session."""
        user = self.repository.get_user_by_email(str(payload.email).lower())
        if user is None or not verify_password(payload.password, user["password_hash"]):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid credentials")
        if not user.get("is_email_verified", False):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Email is not verified")
        if not user.get("is_active", True):
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Account is disabled")
        return self._create_auth_response(user, request)

    def request_password_reset(self, email: str) -> dict[str, str]:
        """Start password recovery while returning a non-enumerating response."""
        email = email.lower()
        user = self.repository.get_user_by_email(email)
        if user is not None and user.get("is_active", True) and user.get("is_email_verified", False):
            try:
                self._send_otp(
                    "password-reset",
                    email,
                    {"user_id": str(user["_id"])},
                    lambda otp: self.email_service.send_password_reset_otp(email, otp),
                )
            except HTTPException as exc:
                if exc.status_code != status.HTTP_429_TOO_MANY_REQUESTS:
                    raise
        return {"detail": "If the email is registered, a password reset code has been sent."}

    def verify_password_reset_otp(self, email: str, otp: str) -> dict[str, str]:
        """Verify a password-reset OTP and issue a short-lived reset grant."""
        email = email.lower()
        record = self.otp_service.verify("password-reset", email, otp)
        return {"reset_token": self.otp_service.create_reset_token(record["user_id"])}

    def reset_password(self, reset_token: str, new_password: str) -> dict[str, str]:
        """Change the password, revoke sessions, and notify the user."""
        try:
            user_id = ObjectId(self.otp_service.consume_reset_token(reset_token))
        except InvalidId as exc:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired reset token") from exc

        user = self.repository.get_user_by_id(user_id)
        if user is None or not user.get("is_active", True):
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired reset token")

        now = utc_now()
        self.repository.update_password(user_id, hash_password(new_password), now)
        self.repository.revoke_all_sessions(user_id, now)
        try:
            self.email_service.send_password_changed(user["email"])
        except Exception:
            pass
        return {"detail": "Password reset successfully. Please log in again."}

    def refresh(self, refresh_token: str) -> TokenPairResponse:
        """Validate and rotate a stored refresh token."""
        try:
            payload = decode_token(refresh_token)
            session_id = ObjectId(payload["sid"])
            user_id = ObjectId(payload["sub"])
        except (jwt.PyJWTError, KeyError, InvalidId, TypeError) as exc:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token") from exc
        if payload.get("type") != "refresh":
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")

        session = self.repository.get_session_by_id(session_id)
        if session is None or session.get("revoked_at") is not None:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session is not active")
        if session["user_id"] != user_id or session["refresh_jti"] != payload.get("jti"):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")
        if session["expires_at"] <= utc_now():
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Session expired")
        if not constant_time_equals(session["refresh_token_hash"], hash_refresh_token(refresh_token)):
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

        now = utc_now()
        new_refresh_jti = create_uuid_token()
        new_refresh_token = create_refresh_token(str(user_id), str(session_id), new_refresh_jti)
        self.repository.rotate_session(session_id, hash_refresh_token(new_refresh_token), new_refresh_jti, now)
        return self._build_token_pair(create_access_token(str(user_id)), new_refresh_token)

    def logout(self, refresh_token: str) -> None:
        """Revoke the refresh session represented by a token when possible."""
        try:
            payload = decode_token(refresh_token)
            session_id = ObjectId(payload["sid"])
        except (jwt.PyJWTError, KeyError, InvalidId, TypeError):
            return
        if payload.get("type") == "refresh":
            self.repository.revoke_session(session_id, utc_now())
