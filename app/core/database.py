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
    """Create MongoDB indexes required by AccessTracker."""

    users = db["users"]
    sessions = db["sessions"]
    applications = db["applications"]
    bugs = db["bugs"]
    verifications = db["verifications"]

    # Authentication indexes
    users.create_index(
        [("email", ASCENDING)],
        unique=True,
        name="uq_users_email",
    )

    sessions.create_index(
        [("refresh_jti", ASCENDING)],
        unique=True,
        name="uq_sessions_refresh_jti",
    )
    sessions.create_index(
        [("user_id", ASCENDING)],
        name="ix_sessions_user_id",
    )
    sessions.create_index(
        [("expires_at", ASCENDING)],
        name="ix_sessions_expires_at",
    )
    sessions.create_index(
        [("revoked_at", ASCENDING)],
        name="ix_sessions_revoked_at",
    )

    # Applications indexes
    applications.create_index(
        [("normalized_name", ASCENDING), ("platform", ASCENDING)],
        unique=True,
        name="uq_applications_normalized_name_platform",
    )

    applications.create_index(
        [("normalized_name", ASCENDING)],
        name="ix_applications_normalized_name",
    )

    # Bugs indexes

    bugs.create_index([("application_id", ASCENDING)], name="ix_bugs_application_id")
    bugs.create_index([("created_by", ASCENDING)], name="ix_bugs_created_by")
    bugs.create_index([("platform", ASCENDING)], name="ix_bugs_platform")
    bugs.create_index([("screen_reader", ASCENDING)], name="ix_bugs_screen_reader")
    bugs.create_index([("created_at", -1)], name="ix_bugs_created_at")
    bugs.create_index([("title", ASCENDING)], name="ix_bugs_title")

    # Verifications indexes
    verifications.create_index([("bug_id", ASCENDING), ("user_id", ASCENDING)], unique=True, name="uq_verifications_bug_user")
    verifications.create_index([("bug_id", ASCENDING)], name="ix_verifications_bug_id")
    verifications.create_index([("user_id", ASCENDING)], name="ix_verifications_user_id")
    verifications.create_index([("verification_type", ASCENDING)], name="ix_verifications_type")