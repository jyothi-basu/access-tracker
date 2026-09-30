"""Business logic for developers and developer responses."""

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException, status
from pymongo.database import Database

from app.applications.service import ApplicationService
from app.bugs.repository import BugRepository
from app.bugs.service import BugService
from app.core.constants import ROLE_DEVELOPER
from app.developers.repository import DeveloperRepository
from app.developers.schemas import (
    CreateDeveloperResponseRequest,
    DeveloperApplicationStatus,
    DeveloperResponse,
    UpdateDeveloperResponseRequest,
)
from app.utils.time import utc_now


class DeveloperService:
    """Business logic for developers and developer responses."""

    def __init__(
        self,
        repository: DeveloperRepository,
        bug_repository: BugRepository,
        bug_service: BugService,
        application_service: ApplicationService,
        db: Database,
    ) -> None:
        self.repository = repository
        self.bug_repository = bug_repository
        self.bug_service = bug_service
        self.application_service = application_service
        self.users = db["users"]

    # ------------------------------------------------------------------
    # Helper methods
    # ------------------------------------------------------------------

    def _validate_developer(
        self,
        current_user_id: ObjectId,
    ) -> None:
        """Ensure the current user has developer role."""

        user = self.users.find_one(
            {"_id": current_user_id},
            {"role": 1},
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found.",
            )

        if user["role"] != ROLE_DEVELOPER:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have developer access.",
            )

    def _validate_application_access(
        self,
        developer_id: ObjectId,
        application_id: ObjectId,
    ) -> None:
        """Ensure the developer is approved for an application."""

        developer_application = (
            self.repository.get_developer_application(
                user_id=developer_id,
                application_id=application_id,
            )
        )

        if developer_application is None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You are not a developer for this application.",
            )

        if (
            developer_application["status"]
            != DeveloperApplicationStatus.APPROVED.value
        ):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Your developer access for this application is not approved.",
            )

    def _get_username(self, user_id: ObjectId) -> str:
        """Return the username for a user."""

        user = self.users.find_one(
            {"_id": user_id},
            {"username": 1},
        )

        if user is None:
            return "Unknown User"

        return user["username"]

    def _build_response(
        self,
        response: dict,
    ) -> DeveloperResponse:
        """Convert a MongoDB document into a DeveloperResponse."""

        return DeveloperResponse(
            _id=str(response["_id"]),
            bug_id=str(response["bug_id"]),
            application_id=str(response["application_id"]),
            developer_id=str(response["developer_id"]),
            developer_username=self._get_username(
                response["developer_id"]
            ),
            response=response["response"],
            created_at=response["created_at"],
            updated_at=response["updated_at"],
        )

    # ------------------------------------------------------------------
    # Public methods
    # ------------------------------------------------------------------

    def get_developer_applications(
        self,
        current_user_id: ObjectId,
    ) -> list[dict]:
        """Return approved applications represented by the developer."""

        self._validate_developer(current_user_id)

        developer_applications = (
            self.repository.get_approved_applications_by_user(
                current_user_id
            )
        )

        applications = []

        for developer_application in developer_applications:
            application_id = developer_application["application_id"]

            try:
                application = self.application_service.get_application(
                    str(application_id)
                )
            except HTTPException as exc:
                if exc.status_code == status.HTTP_404_NOT_FOUND:
                    continue
                raise

            bug_count = self.bug_repository.count_bugs_by_application(
                application_id
            )

            applications.append(
                {
                    "application_id": str(application_id),
                    "application_name": application.display_name,
                    "bug_count": bug_count,
                }
            )

        return applications

    def get_bug_responses(
        self,
        bug_id: str,
    ) -> list[DeveloperResponse]:
        """Return all developer responses for a bug."""

        # BugService handles ObjectId validation and 404 handling.
        bug = self.bug_service.get_bug_by_id(bug_id)

        responses = self.repository.get_responses_by_bug(
            ObjectId(bug.id)
        )

        return [
            self._build_response(response)
            for response in responses
        ]

    def get_my_responses(
        self,
        current_user_id: ObjectId,
    ) -> list[DeveloperResponse]:
        """Return all responses created by the current developer."""

        self._validate_developer(current_user_id)

        responses = self.repository.get_responses_by_developer(
            current_user_id
        )

        return [
            self._build_response(response)
            for response in responses
        ]

    def create_response(
        self,
        bug_id: str,
        payload: CreateDeveloperResponseRequest,
        current_user_id: ObjectId,
    ) -> DeveloperResponse:
        """Create a developer response for a bug."""

        self._validate_developer(current_user_id)

        # BugService handles bug ID validation and 404 handling.
        bug = self.bug_service.get_bug_by_id(bug_id)

        try:
            parsed_bug_id = ObjectId(bug.id)
            application_id = ObjectId(bug.application_id)
        except InvalidId as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid bug or application ID.",
            ) from exc

        self._validate_application_access(
            developer_id=current_user_id,
            application_id=application_id,
        )

        now = utc_now()

        response_document = {
            "bug_id": parsed_bug_id,
            "application_id": application_id,
            "developer_id": current_user_id,
            "response": payload.response,
            "created_at": now,
            "updated_at": now,
        }

        response_id = self.repository.create_response(
            response_document
        )

        response = self.repository.get_response_by_id(
            response_id
        )

        return self._build_response(response)

    def update_response(
        self,
        response_id: str,
        payload: UpdateDeveloperResponseRequest,
        current_user_id: ObjectId,
    ) -> DeveloperResponse:
        """Update a developer's own response."""

        self._validate_developer(current_user_id)

        try:
            parsed_response_id = ObjectId(response_id)
        except InvalidId as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid response ID.",
            ) from exc

        response = self.repository.get_response_by_id(
            parsed_response_id
        )

        if response is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Developer response not found.",
            )

        if response["developer_id"] != current_user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only edit your own responses.",
            )

        updates = payload.model_dump(exclude_none=True)

        if not updates:
            return self._build_response(response)

        updated = self.repository.update_response(
            response_id=parsed_response_id,
            updates=updates,
            updated_at=utc_now(),
        )

        if not updated:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Developer response no longer exists.",
            )

        updated_response = self.repository.get_response_by_id(
            parsed_response_id
        )

        if updated_response is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Developer response no longer exists.",
            )

        return self._build_response(updated_response)

    def delete_response(
        self,
        response_id: str,
        current_user_id: ObjectId,
    ) -> None:
        """Delete a developer's own response."""

        self._validate_developer(current_user_id)

        try:
            parsed_response_id = ObjectId(response_id)
        except InvalidId as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid response ID.",
            ) from exc

        response = self.repository.get_response_by_id(
            parsed_response_id
        )

        if response is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Developer response not found.",
            )

        if response["developer_id"] != current_user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only delete your own responses.",
            )

        deleted = self.repository.delete_response(parsed_response_id)

        if not deleted:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Developer response no longer exists.",
            )
