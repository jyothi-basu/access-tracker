"""Business logic for accessibility bug reports."""

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException, status
from pymongo.database import Database

from app.applications.service import ApplicationService
from app.bugs.repository import BugRepository
from app.bugs.schemas import (
    BugListResponse,
    BugResponse,
    CreateBugRequest,
    UpdateBugRequest,
)
from app.utils.time import utc_now
from app.core.constants import ROLE_ADMIN


class BugService:
    """Business logic for accessibility bug reports."""

    def __init__(
        self,
        bug_repository: BugRepository,
        application_service: ApplicationService,
        db: Database,
    ) -> None:
        self.repository = bug_repository
        self.application_service = application_service
        self.users = db["users"]

    # ------------------------------------------------------------------
    # Helper methods
    # ------------------------------------------------------------------

    def _parse_bug_id(self, bug_id: str) -> ObjectId:
        """Convert string bug ID into ObjectId."""

        try:
            return ObjectId(bug_id)
        except InvalidId as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid bug ID.",
            ) from exc

    def _get_bug_or_404(self, bug_id: str) -> dict:
        """Return a bug document or raise 404."""

        bug = self.repository.get_bug_by_id(self._parse_bug_id(bug_id))

        if bug is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bug report not found.",
            )

        return bug

    def _validate_bug_owner(
        self,
        bug: dict,
        current_user_id: ObjectId,
    ) -> None:
        """Allow the bug owner or an admin to modify the bug."""

        user = self.users.find_one(
            {"_id": current_user_id},
            {"role": 1},
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found.",
            )

        if user["role"] == ROLE_ADMIN:
            return

        if bug["created_by"] != current_user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You can only modify your own bug reports.",
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

    def _build_bug_document(
        self,
        payload: CreateBugRequest,
        application_id: ObjectId,
        created_by: ObjectId,
    ) -> dict:
        """Create MongoDB document for insertion."""

        now = utc_now()

        return {
            "application_id": application_id,
            "platform": payload.platform.value,
            "app_version": payload.app_version,
            "title": payload.title,
            "actual_behavior": payload.actual_behavior,
            "expected_behavior": payload.expected_behavior,
            "screen_reader": payload.screen_reader.value,
            "severity": payload.severity.value,
            "steps_to_reproduce": payload.steps_to_reproduce,
            "screen_reader_version": payload.screen_reader_version,
            "device_model": payload.device_model,
            "created_by": created_by,
            "created_at": now,
            "updated_at": now,
        }

    def _build_bug_response(self, bug: dict) -> BugResponse:
        """Convert MongoDB document into BugResponse."""

        application = self.application_service.get_application(
            str(bug["application_id"])
        )

        return BugResponse(
            _id=str(bug["_id"]),
            reporter_username=self._get_username(bug["created_by"]),
            application_id=str(bug["application_id"]),
            application_name=application.display_name,
            platform=bug["platform"],
            app_version=bug["app_version"],
            title=bug["title"],
            actual_behavior=bug["actual_behavior"],
            expected_behavior=bug["expected_behavior"],
            screen_reader=bug["screen_reader"],
            severity=bug["severity"],
            steps_to_reproduce=bug.get("steps_to_reproduce"),
            screen_reader_version=bug.get("screen_reader_version"),
            device_model=bug.get("device_model"),
            created_by=str(bug["created_by"]),
            created_at=bug["created_at"],
            updated_at=bug["updated_at"],
        )
    # ------------------------------------------------------------------
    # Public methods
    # ------------------------------------------------------------------

    def create_bug(
        self,
        payload: CreateBugRequest,
        current_user_id: ObjectId,
    ) -> BugResponse:
        """Create a new accessibility bug report."""

        application = self.application_service.find_or_create_application(
            application_name=payload.application_name,
            platform=payload.platform.value,
            created_by=current_user_id,
        )

        bug_document = self._build_bug_document(
            payload=payload,
            application_id=application.id,
            created_by=current_user_id,
        )

        bug_id = self.repository.create_bug(bug_document)

        bug = self.repository.get_bug_by_id(bug_id)

        return self._build_bug_response(bug)

    def search_bugs(
        self,
        search: str | None = None,
        application_name: str | None = None,
        platform: str | None = None,
        screen_reader: str | None = None,
        severity: str | None = None,
    ) -> BugListResponse:
        """Search accessibility bug reports."""

        application_id = None

        if application_name:
            applications = self.application_service.search_applications(
                application_name
            )

            if not applications:
                return BugListResponse(bugs=[])

            application_id = applications[0].id

        bugs = self.repository.search_bugs(
            search=search,
            application_id=application_id,
            platform=platform,
            screen_reader=screen_reader,
            severity=severity,
        )

        return BugListResponse(
            bugs=[
                self._build_bug_response(bug)
                for bug in bugs
            ]
        )

    def get_bug_by_id(self, bug_id: str) -> BugResponse:
        """Return one bug report."""

        bug = self._get_bug_or_404(bug_id)
        return self._build_bug_response(bug)

    def get_bugs_by_user(
        self,
        current_user_id: ObjectId,
    ) -> BugListResponse:
        """Return bug reports created by one user."""

        bugs = self.repository.get_bugs_by_user(current_user_id)

        return BugListResponse(
            bugs=[
                self._build_bug_response(bug)
                for bug in bugs
            ]
        )

    def update_bug(
        self,
        bug_id: str,
        payload: UpdateBugRequest,
        current_user_id: ObjectId,
    ) -> BugResponse:
        """Update an existing bug report."""

        bug = self._get_bug_or_404(bug_id)
        self._validate_bug_owner(bug, current_user_id)

        updates = payload.model_dump(exclude_none=True)

        if "severity" in updates:
            updates["severity"] = updates["severity"].value

        if not updates:
            return self._build_bug_response(bug)

        self.repository.update_bug(
            bug_id=bug["_id"],
            updates=updates,
            updated_at=utc_now(),
        )

        updated_bug = self.repository.get_bug_by_id(bug["_id"])

        return self._build_bug_response(updated_bug)

    def delete_bug(
        self,
        bug_id: str,
        current_user_id: ObjectId,
    ) -> None:
        """Delete a bug report."""

        bug = self._get_bug_or_404(bug_id)
        self._validate_bug_owner(bug, current_user_id)

        self.repository.delete_bug(bug["_id"])