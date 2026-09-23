"""Password hashing, JWT, and token-hashing security helpers."""

from datetime import datetime, timedelta, timezone
import hashlib
import hmac
import secrets

from argon2 import PasswordHasher
from argon2.low_level import Type
import jwt

from app.core.config import get_settings

settings = get_settings()

password_hasher = PasswordHasher(
    time_cost=settings.password_hash_time_cost,
    memory_cost=settings.password_hash_memory_cost,
    parallelism=settings.password_hash_parallelism,
    hash_len=32,
    salt_len=16,
    type=Type.ID,
)


def utc_now() -> datetime:
    """Return the current timezone-aware UTC time."""
    return datetime.now(timezone.utc)


def create_uuid_token() -> str:
    """Generate a cryptographically secure random token identifier."""
    return secrets.token_urlsafe(48)


def hash_password(password: str) -> str:
    """Hash a password with Argon2id using configured cost parameters."""
    return password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    """Verify a password against an Argon2id hash without leaking errors."""
    try:
        return password_hasher.verify(password_hash, password)
    except Exception:
        return False


def create_access_token(subject: str) -> str:
    """Create a short-lived JWT used to access protected API endpoints."""
    now = utc_now()
    payload = {
        "sub": subject,
        "type": "access",
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.access_token_exp_minutes)).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_refresh_token(subject: str, session_id: str, token_id: str) -> str:
    """Create a JWT that identifies one stored refresh-token session."""
    now = utc_now()
    payload = {
        "sub": subject,
        "sid": session_id,
        "jti": token_id,
        "type": "refresh",
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(days=settings.refresh_token_exp_days)).timestamp()),
    }
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def decode_token(token: str) -> dict:
    """Decode and validate a JWT signature, algorithm, and expiration."""
    return jwt.decode(token, settings.jwt_secret_key, algorithms=[settings.jwt_algorithm])


def hash_refresh_token(token: str) -> str:
    """Hash a refresh token with the server-side pepper before persistence."""
    data = f"{token}{settings.refresh_token_pepper}".encode("utf-8")
    return hashlib.sha256(data).hexdigest()


def constant_time_equals(a: str, b: str) -> bool:
    """Compare secrets without exposing timing differences."""
    return hmac.compare_digest(a, b)
