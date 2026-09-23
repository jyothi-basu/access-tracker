"""MongoDB client lifecycle and application indexes."""

from functools import lru_cache

from pymongo import MongoClient
from pymongo import ASCENDING
from pymongo.database import Database

from app.core.config import get_settings


@lru_cache(maxsize=1)
def get_mongo_client() -> MongoClient:
    """Return the process-wide MongoDB client."""
    settings = get_settings()
    return MongoClient(settings.mongo_uri)


def get_database() -> Database:
    """Return the configured AccessTracker database."""
    settings = get_settings()
    return get_mongo_client()[settings.mongo_db_name]


def init_database_indexes(db: Database) -> None:
    """Create unique and query-supporting indexes required by authentication."""
    users = db["users"]
    sessions = db["sessions"]

    users.create_index([("email", ASCENDING)], unique=True, name="uq_users_email")
    sessions.create_index([("refresh_jti", ASCENDING)], unique=True, name="uq_sessions_refresh_jti")
    sessions.create_index([("user_id", ASCENDING)], name="ix_sessions_user_id")
    sessions.create_index([("expires_at", ASCENDING)], name="ix_sessions_expires_at")
    sessions.create_index([("revoked_at", ASCENDING)], name="ix_sessions_revoked_at")
