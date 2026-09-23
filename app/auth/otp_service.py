"""Redis-backed, purpose-specific one-time-password challenges."""

import hashlib
import hmac
import json
import secrets

from fastapi import HTTPException, status
from redis import Redis

from app.core.config import get_settings


class OtpService:
    """Create, verify, expire, and consume authentication challenges in Redis."""

    def __init__(self, redis: Redis) -> None:
        """Initialize the service with a Redis client."""
        self.redis = redis
        self.settings = get_settings()

    def _key(self, purpose: str, email: str) -> str:
        return f"auth:otp:{purpose}:{email}"

    def _cooldown_key(self, purpose: str, email: str) -> str:
        return f"auth:otp-cooldown:{purpose}:{email}"

    def _hash_otp(self, otp: str) -> str:
        return hmac.new(
            self.settings.otp_pepper.encode(), otp.encode(), hashlib.sha256
        ).hexdigest()

    def create(self, purpose: str, email: str, data: dict) -> str:
        """Create a six-digit OTP and store only its protected representation."""
        if self.redis.exists(self._cooldown_key(purpose, email)):
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Please wait before requesting another code",
            )

        otp = f"{secrets.randbelow(1_000_000):06d}"
        record = {**data, "otp_hash": self._hash_otp(otp), "attempts": 0}
        self.redis.setex(
            self._key(purpose, email),
            self.settings.otp_expire_seconds,
            json.dumps(record),
        )
        self.redis.setex(
            self._cooldown_key(purpose, email),
            self.settings.otp_resend_cooldown_seconds,
            "1",
        )
        return otp

    def verify(self, purpose: str, email: str, otp: str) -> dict:
        """Verify a single-use OTP while enforcing expiry and attempt limits."""
        key = self._key(purpose, email)
        raw_record = self.redis.get(key)
        if raw_record is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

        record = json.loads(raw_record)
        if record["attempts"] >= self.settings.otp_max_attempts:
            self.redis.delete(key)
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Too many invalid attempts")

        if not hmac.compare_digest(record["otp_hash"], self._hash_otp(otp)):
            self.redis.set(key, json.dumps({**record, "attempts": record["attempts"] + 1}), keepttl=True)
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired code")

        self.redis.delete(key)
        return record

    def get(self, purpose: str, email: str) -> dict | None:
        """Return an active challenge without consuming it, if one exists."""
        raw_record = self.redis.get(self._key(purpose, email))
        return json.loads(raw_record) if raw_record is not None else None

    def delete(self, purpose: str, email: str) -> None:
        """Remove a challenge and its resend cooldown."""
        self.redis.delete(self._key(purpose, email), self._cooldown_key(purpose, email))

    def create_reset_token(self, user_id: str) -> str:
        """Create a short-lived, single-use password-reset grant."""
        token = secrets.token_urlsafe(32)
        token_hash = self._hash_otp(token)
        self.redis.setex(
            f"auth:password-reset-token:{token_hash}",
            self.settings.password_reset_token_expire_seconds,
            user_id,
        )
        return token

    def consume_reset_token(self, token: str) -> str:
        """Consume a reset grant and return the associated user ID."""
        token_hash = self._hash_otp(token)
        key = f"auth:password-reset-token:{token_hash}"
        user_id = self.redis.getdel(key)
        if user_id is None:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Invalid or expired reset token")
        return user_id
