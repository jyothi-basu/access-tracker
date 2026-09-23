"""Redis client lifecycle for temporary auth data and reset grants."""

from functools import lru_cache

from redis import Redis

from app.core.config import get_settings


@lru_cache(maxsize=1)
def get_redis() -> Redis:
    """Return the process-wide Redis client configured by the environment."""
    return Redis.from_url(get_settings().redis_url, decode_responses=True)
