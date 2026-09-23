"""MongoDB persistence operations used by the authentication service."""

from datetime import datetime

from pymongo.database import Database


class AuthRepository:
    """Encapsulate user and refresh-session persistence for auth use cases."""

    def __init__(self, db: Database) -> None:
        """Bind the repository to the users and sessions collections."""
        self.users = db["users"]
        self.sessions = db["sessions"]

    def get_user_by_email(self, email: str) -> dict | None:
        """Find a user by normalized email address."""
        return self.users.find_one({"email": email.lower()})

    def get_user_by_id(self, user_id) -> dict | None:
        """Find a user by MongoDB identifier."""
        return self.users.find_one({"_id": user_id})

    def create_user(self, user: dict) -> str:
        """Insert a verified user and return its identifier as a string."""
        result = self.users.insert_one(user)
        return str(result.inserted_id)

    def update_user_last_login(self, user_id, last_login_at: datetime) -> None:
        """Record the latest successful login time."""
        self.users.update_one(
            {"_id": user_id},
            {"$set": {"last_login_at": last_login_at, "updated_at": last_login_at}},
        )

    def update_password(self, user_id, password_hash: str, updated_at: datetime) -> None:
        """Replace a user's password hash and modification timestamp."""
        self.users.update_one(
            {"_id": user_id},
            {"$set": {"password_hash": password_hash, "updated_at": updated_at}},
        )

    def revoke_all_sessions(self, user_id, revoked_at: datetime) -> None:
        """Revoke every active refresh session belonging to a user."""
        self.sessions.update_many(
            {"user_id": user_id, "revoked_at": None},
            {"$set": {"revoked_at": revoked_at}},
        )

    def create_session(self, session: dict) -> str:
        """Persist a refresh-token-backed login session."""
        result = self.sessions.insert_one(session)
        return str(result.inserted_id)

    def get_session_by_id(self, session_id) -> dict | None:
        """Find a refresh session by its identifier."""
        return self.sessions.find_one({"_id": session_id})

    def get_session_by_jti(self, refresh_jti: str) -> dict | None:
        """Find a refresh session by refresh-token ID."""
        return self.sessions.find_one({"refresh_jti": refresh_jti})

    def rotate_session(self, session_id, refresh_token_hash: str, refresh_jti: str, last_used_at: datetime) -> None:
        """Replace the stored refresh token during token rotation."""
        self.sessions.update_one(
            {"_id": session_id},
            {
                "$set": {
                    "refresh_token_hash": refresh_token_hash,
                    "refresh_jti": refresh_jti,
                    "last_used_at": last_used_at,
                }
            },
        )

    def revoke_session(self, session_id, revoked_at: datetime) -> None:
        """Mark one refresh session as revoked."""
        self.sessions.update_one(
            {"_id": session_id},
            {"$set": {"revoked_at": revoked_at}},
        )
