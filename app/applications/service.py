"""Business logic for the Applications feature."""

from bson import ObjectId
from fastapi import HTTPException, status

from app.applications.repository import ApplicationRepository
from app.applications.schemas import (
    ApplicationResponse,
    CreateApplicationRequest,
)
from app.utils.time import utc_now


class ApplicationService:
    """Handle application business logic."""

    def __init__(self, repository: ApplicationRepository) -> None:
        self.repository = repository

    def _normalize_application_name(self, name: str) -> str:
        """Normalize application names for duplicate detection and search."""
        normalized = " ".join(name.strip().split())
        normalized = normalized.lower()
        normalized = normalized.replace("-", "").replace("_", "")
        return normalized

    def _build_application_response(self, document: dict) -> ApplicationResponse:
        """Convert a MongoDB document into an API response."""
        return ApplicationResponse(
            id=str(document["_id"]),
            display_name=document["display_name"],
            platform=document["platform"],
        )

    def create_application(
        self,
        payload: CreateApplicationRequest,
        current_user_id: ObjectId,
    ) -> ApplicationResponse:
        """Create an application or return the existing one."""
        normalized_name = self._normalize_application_name(payload.display_name)

        existing_application = self.repository.find_by_normalized_name(
            normalized_name=normalized_name,
            platform=payload.platform.value,
        )

        if existing_application:
            return self._build_application_response(existing_application)

        now = utc_now()

        document = {
            "display_name": payload.display_name,
            "normalized_name": normalized_name,
            "platform": payload.platform.value,
            "developer_user_ids": [],
            "website": None,
            "created_by": current_user_id,
            "created_at": now,
            "updated_at": now,
        }

        created_application = self.repository.create_application(document)

        return self._build_application_response(created_application)

    def find_or_create_application(
        self,
        application_name: str,
        platform: Platform,
        created_by: ObjectId,
    ) -> ApplicationResponse:
        """Return an existing application or create a new one."""

        normalized_name = self._normalize_application_name(application_name)

        application = self.repository.find_by_normalized_name(
            normalized_name=normalized_name,
            platform=platform.value,
        )

        if application is not None:
            return self._build_application_response(application)

        payload = CreateApplicationRequest(
            display_name=application_name,
            platform=platform,
        )

        return self.create_application(
            payload=payload,
            current_user_id=created_by,
        )

    def search_applications(
        self,
        search: str | None,
    ) -> list[ApplicationResponse]:
        """Search applications by name. Empty search returns all applications."""
        normalized_query = ""

        if search:
            normalized_query = self._normalize_application_name(search)

        applications = self.repository.search_applications(normalized_query)

        return [
            self._build_application_response(application)
            for application in applications
        ]

    def get_application(self, application_id: str) -> ApplicationResponse:
        """Return a single application by its ID."""
        application = self.repository.get_application_by_id(application_id)

        if application is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Application not found.",
            )

        return self._build_application_response(application)