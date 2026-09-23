"""MongoDB repository for application operations."""

from bson import ObjectId
from pymongo.database import Database


class ApplicationRepository:
    """Handle all MongoDB operations for applications."""

    def __init__(self, db: Database) -> None:
        self.collection = db["applications"]

    def create_application(self, document: dict) -> dict:
        """Insert a new application document and return it."""
        result = self.collection.insert_one(document)
        document["_id"] = result.inserted_id
        return document

    def find_by_normalized_name(
        self,
        normalized_name: str,
        platform: str,
    ) -> dict | None:
        """Find an application by normalized name and platform."""
        return self.collection.find_one(
            {
                "normalized_name": normalized_name,
                "platform": platform,
            }
        )

    def search_applications(self, query: str) -> list[dict]:
        """Search applications by display name."""
        cursor = self.collection.find(
            {
                "normalized_name": {
                    "$regex": query,
                    "$options": "i",
                }
            }
        ).sort("display_name", 1)

        return list(cursor)

    def get_application_by_id(self, application_id: str) -> dict | None:
        """Fetch an application using its MongoDB ObjectId."""
        if not ObjectId.is_valid(application_id):
            return None

        return self.collection.find_one(
            {"_id": ObjectId(application_id)}
        )