"""MongoDB repository for developer applications and responses."""

from datetime import datetime

from bson import ObjectId
from pymongo.collection import Collection
from pymongo.database import Database


class DeveloperRepository:
    """Repository for developer applications and responses."""

    def __init__(self, db: Database) -> None:
        self.applications: Collection = db["developer_applications"]
        self.responses: Collection = db["developer_responses"]

    # Developer applications

    def get_developer_application(
        self,
        user_id: ObjectId,
        application_id: ObjectId,
    ) -> dict | None:
        """Return a developer application for a user and application."""
        return self.applications.find_one(
            {
                "user_id": user_id,
                "application_id": application_id,
            }
        )

    def get_approved_applications_by_user(
        self,
        user_id: ObjectId,
    ) -> list[dict]:
        """Return approved developer applications for one user."""

        cursor = (
            self.applications
            .find(
                {
                    "user_id": user_id,
                    "status": "approved",
                }
            )
            .sort("created_at", -1)
        )

        return list(cursor)

    # Developer responses

    def create_response(self, response: dict) -> ObjectId:
        """Insert a developer response and return its ID."""
        result = self.responses.insert_one(response)
        return result.inserted_id

    def get_responses_by_bug(self, bug_id: ObjectId) -> list[dict]:
        """Return all developer responses for a bug."""

        cursor = (
            self.responses
            .find({"bug_id": bug_id})
            .sort("updated_at", -1)
        )

        return list(cursor)

    def get_responses_by_developer(
        self,
        developer_id: ObjectId,
    ) -> list[dict]:
        """Return all responses created by one developer."""

        cursor = (
            self.responses
            .find({"developer_id": developer_id})
            .sort("updated_at", -1)
        )

        return list(cursor)

    def get_response_by_id(
        self,
        response_id: ObjectId,
    ) -> dict | None:
        """Return a developer response by its ID."""
        return self.responses.find_one({"_id": response_id})

    def update_response(
        self,
        response_id: ObjectId,
        updates: dict,
        updated_at: datetime,
    ) -> bool:
        """Update a developer response."""

        updates["updated_at"] = updated_at

        result = self.responses.update_one(
            {"_id": response_id},
            {"$set": updates},
        )

        return result.modified_count > 0

    def delete_response(self, response_id: ObjectId) -> bool:
        """Delete a developer response."""

        result = self.responses.delete_one({"_id": response_id})
        return result.deleted_count > 0
