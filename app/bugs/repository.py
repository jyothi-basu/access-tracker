"""MongoDB repository for accessibility bug reports."""

from datetime import datetime

from bson import ObjectId
from pymongo import ASCENDING
from pymongo.collection import Collection
from pymongo.database import Database


class BugRepository:
    """Repository for CRUD operations on bug reports."""

    def __init__(self, db: Database) -> None:
        self.collection: Collection = db["bugs"]

    def create_bug(self, bug: dict) -> ObjectId:
        """Insert a new bug report and return its ID."""
        result = self.collection.insert_one(bug)
        return result.inserted_id

    def get_bug_by_id(self, bug_id: ObjectId) -> dict | None:
        """Return a bug report by its ID."""
        return self.collection.find_one({"_id": bug_id})

    def search_bugs(
        self,
        search: str | None = None,
        application_id: ObjectId | None = None,
        platform: str | None = None,
        screen_reader: str | None = None,
        severity: str | None = None,
    ) -> list[dict]:
        """Search bug reports using optional filters."""

        query: dict = {}

        if search:
            query["title"] = {
                "$regex": search,
                "$options": "i",
            }

        if application_id:
            query["application_id"] = application_id

        if platform:
            query["platform"] = platform

        if screen_reader:
            query["screen_reader"] = screen_reader

        if severity:
            query["severity"] = severity

        cursor = (
            self.collection
            .find(query)
            .sort("created_at", -1)
        )

        return list(cursor)

    def get_bugs_by_user(self, user_id: ObjectId) -> list[dict]:
        """Return all bug reports created by one user."""

        cursor = (
            self.collection
            .find({"created_by": user_id})
            .sort("created_at", -1)
        )

        return list(cursor)

    def update_bug(
        self,
        bug_id: ObjectId,
        updates: dict,
        updated_at: datetime,
    ) -> bool:
        """Update a bug report."""

        updates["updated_at"] = updated_at

        result = self.collection.update_one(
            {"_id": bug_id},
            {"$set": updates},
        )

        return result.modified_count > 0

    def delete_bug(self, bug_id: ObjectId) -> bool:
        """Delete a bug report."""

        result = self.collection.delete_one({"_id": bug_id})
        return result.deleted_count > 0
