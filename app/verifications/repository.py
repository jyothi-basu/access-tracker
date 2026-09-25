"""MongoDB repository for bug verifications."""

from datetime import datetime

from bson import ObjectId
from pymongo import DESCENDING
from pymongo.collection import Collection
from pymongo.database import Database


class VerificationRepository:
    """Repository for CRUD operations on bug verifications."""

    def __init__(self, db: Database) -> None:
        self.collection: Collection = db["verifications"]

    def create_verification(self, verification: dict) -> ObjectId:
        """Insert a verification and return its ID."""
        result = self.collection.insert_one(verification)
        return result.inserted_id

    def get_verification(
        self,
        bug_id: ObjectId,
        user_id: ObjectId,
    ) -> dict | None:
        """Return one user's verification for a bug."""
        return self.collection.find_one(
            {
                "bug_id": bug_id,
                "user_id": user_id,
            }
        )

    def get_verification_by_id(
        self,
        verification_id: ObjectId,
    ) -> dict | None:
        """Return a verification by its MongoDB ID."""
        return self.collection.find_one({"_id": verification_id})

    def get_bug_verifications(
        self,
        bug_id: ObjectId,
    ) -> list[dict]:
        """Return all verifications for a bug."""
        cursor = (
            self.collection
            .find({"bug_id": bug_id})
            .sort("updated_at", DESCENDING)
        )

        return list(cursor)

    def get_user_verifications(
        self,
        user_id: ObjectId,
    ) -> list[dict]:
        """Return all verifications created by a user."""
        cursor = (
            self.collection
            .find({"user_id": user_id})
            .sort("updated_at", DESCENDING)
        )

        return list(cursor)

    def update_verification(
        self,
        bug_id: ObjectId,
        user_id: ObjectId,
        updates: dict,
        updated_at: datetime,
    ) -> bool:
        """Update an existing verification."""

        updates["updated_at"] = updated_at

        result = self.collection.update_one(
            {
                "bug_id": bug_id,
                "user_id": user_id,
            },
            {
                "$set": updates,
            },
        )

        return result.modified_count > 0

    def delete_verification(
        self,
        bug_id: ObjectId,
        user_id: ObjectId,
    ) -> bool:
        """Delete a user's verification for a bug."""

        result = self.collection.delete_one(
            {
                "bug_id": bug_id,
                "user_id": user_id,
            }
        )

        return result.deleted_count > 0

    def get_verification_summary(
        self,
        bug_id: ObjectId,
    ) -> dict[str, int]:
        """Return verification counts grouped by type."""

        pipeline = [
            {"$match": {"bug_id": bug_id}},
            {
                "$group": {
                    "_id": "$verification_type",
                    "count": {"$sum": 1},
                }
            },
        ]

        result = {
            "present": 0,
            "fixed": 0,
            "not_present": 0,
        }

        for item in self.collection.aggregate(pipeline):
            result[item["_id"]] = item["count"]

        return result
