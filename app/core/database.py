"""MongoDB client lifecycle and application indexes."""

from functools import lru_cache

from pymongo import ASCENDING, DESCENDING, MongoClient
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
    developer_applications = db["developer_applications"]
    developer_responses = db["developer_responses"]

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
    bugs.create_index(
        [("application_id", ASCENDING)],
        name="ix_bugs_application_id",
    )
    bugs.create_index(
        [("created_by", ASCENDING)],
        name="ix_bugs_created_by",
    )
    bugs.create_index(
        [("platform", ASCENDING)],
        name="ix_bugs_platform",
    )
    bugs.create_index(
        [("screen_reader", ASCENDING)],
        name="ix_bugs_screen_reader",
    )
    bugs.create_index(
        [("created_at", DESCENDING)],
        name="ix_bugs_created_at",
    )
    bugs.create_index(
        [("title", ASCENDING)],
        name="ix_bugs_title",
    )

    # Verifications indexes
    verifications.create_index(
        [("bug_id", ASCENDING), ("user_id", ASCENDING)],
        unique=True,
        name="uq_verifications_bug_user",
    )
    verifications.create_index(
        [("bug_id", ASCENDING)],
        name="ix_verifications_bug_id",
    )
    verifications.create_index(
        [("user_id", ASCENDING)],
        name="ix_verifications_user_id",
    )
    verifications.create_index(
        [("verification_type", ASCENDING)],
        name="ix_verifications_type",
    )

    # Developer applications indexes
    developer_applications.create_index(
        [("user_id", ASCENDING), ("application_id", ASCENDING)],
        unique=True,
        name="uq_developer_applications_user_application",
    )
    developer_applications.create_index(
        [("user_id", ASCENDING), ("status", ASCENDING)],
        name="ix_developer_applications_user_status",
    )

    # Developer responses indexes
    developer_responses.create_index(
        [("bug_id", ASCENDING), ("updated_at", DESCENDING)],
        name="ix_developer_responses_bug_updated_at",
    )
    developer_responses.create_index(
        [("developer_id", ASCENDING), ("updated_at", DESCENDING)],
        name="ix_developer_responses_developer_updated_at",
    )