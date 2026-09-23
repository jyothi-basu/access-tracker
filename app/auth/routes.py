"""HTTP routes for registration, authentication, and password recovery."""

from fastapi import APIRouter, Depends, Request
from pymongo.database import Database
from redis import Redis

from app.auth.email_service import EmailService
from app.auth.otp_service import OtpService
from app.auth.repository import AuthRepository
from app.auth.schemas import (
    AuthResponse,
    LoginRequest,
    LogoutRequest,
    MessageResponse,
    OtpRequest,
    RefreshRequest,
    RegisterRequest,
    ResetPasswordRequest,
    ResetTokenResponse,
    TokenPairResponse,
    UserResponse,
    VerifyRegistrationRequest,
)
from app.auth.service import AuthService
from app.core.database import get_database
from app.core.dependencies import get_current_user_id
from app.core.redis import get_redis

router = APIRouter()


def get_auth_service(
    db: Database = Depends(get_database),
    redis: Redis = Depends(get_redis),
) -> AuthService:
    """Build the authentication service with request-scoped dependencies."""
    return AuthService(AuthRepository(db), OtpService(redis), EmailService())


@router.post("/register", response_model=MessageResponse)
def register(payload: RegisterRequest, service: AuthService = Depends(get_auth_service)) -> dict[str, str]:
    """Start registration by storing pending data and emailing a verification OTP."""
    return service.request_registration(payload)


@router.post("/register/resend-otp", response_model=MessageResponse)
def resend_registration_otp(
    payload: OtpRequest,
    service: AuthService = Depends(get_auth_service),
) -> dict[str, str]:
    """Send another registration OTP when the resend cooldown allows it."""
    return service.resend_registration_otp(str(payload.email))


@router.post("/register/verify", response_model=MessageResponse)
def verify_registration(
    payload: VerifyRegistrationRequest,
    service: AuthService = Depends(get_auth_service),
) -> dict[str, str]:
    """Verify the registration OTP and create the MongoDB user."""
    return service.verify_registration(str(payload.email), payload.otp)


@router.post("/login", response_model=AuthResponse)
def login(
    payload: LoginRequest,
    request: Request,
    service: AuthService = Depends(get_auth_service),
) -> AuthResponse:
    """Authenticate a verified user and create a refresh-token session."""
    return service.login(payload, request)


@router.post("/refresh", response_model=TokenPairResponse)
def refresh(payload: RefreshRequest, service: AuthService = Depends(get_auth_service)) -> TokenPairResponse:
    """Rotate a refresh token and issue a new access-token pair."""
    return service.refresh(payload.refresh_token)


@router.post("/logout", response_model=MessageResponse)
def logout(payload: LogoutRequest, service: AuthService = Depends(get_auth_service)) -> dict[str, str]:
    """Revoke the refresh-token session associated with the supplied token."""
    service.logout(payload.refresh_token)
    return {"detail": "Logged out"}


@router.post("/forgot-password/request-otp", response_model=MessageResponse)
def request_password_reset(
    payload: OtpRequest,
    service: AuthService = Depends(get_auth_service),
) -> dict[str, str]:
    """Start password recovery by emailing an OTP without revealing account existence."""
    return service.request_password_reset(str(payload.email))


@router.post("/forgot-password/verify-otp", response_model=ResetTokenResponse)
def verify_password_reset_otp(
    payload: VerifyRegistrationRequest,
    service: AuthService = Depends(get_auth_service),
) -> dict[str, str]:
    """Exchange a valid password-reset OTP for a short-lived reset grant."""
    return service.verify_password_reset_otp(str(payload.email), payload.otp)


@router.post("/forgot-password/reset", response_model=MessageResponse)
def reset_password(
    payload: ResetPasswordRequest,
    service: AuthService = Depends(get_auth_service),
) -> dict[str, str]:
    """Set a new password using a valid, single-use reset grant."""
    return service.reset_password(payload.reset_token, payload.new_password)


@router.get("/me", response_model=UserResponse)
def me(
    current_user_id=Depends(get_current_user_id),
    service: AuthService = Depends(get_auth_service),
) -> UserResponse:
    """Return the authenticated user's profile."""
    return service.get_current_user(current_user_id)
