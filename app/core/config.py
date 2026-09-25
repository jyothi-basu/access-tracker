"""Environment-backed application configuration."""

from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Validated configuration values for the API and auth services."""
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    app_name: str = "AccessTracker"
    api_v1_prefix: str = "/api/v1"
    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db_name: str = "access_tracker"
    redis_url: str = "redis://localhost:6379/0"
    resend_api_key: str = ""
    resend_from_email: str = ""
    jwt_secret_key: str = "change-me"
    jwt_algorithm: str = "HS256"
    access_token_exp_minutes: int = 30
    refresh_token_exp_days: int = 7
    refresh_token_pepper: str = "change-me-too"
    otp_pepper: str = "change-me-otp"
    otp_expire_seconds: int = 600
    otp_resend_cooldown_seconds: int = 60
    otp_max_attempts: int = 5
    password_reset_token_expire_seconds: int = 600
    password_hash_time_cost: int = 2
    password_hash_memory_cost: int = 102400
    password_hash_parallelism: int = 8
    first_admin_email: str

@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return the cached application settings instance."""
    return Settings()
