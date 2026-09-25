"""Business logic for bug verifications."""

from bson import ObjectId
from bson.errors import InvalidId
from fastapi import HTTPException, status
from pymongo.database import Database

from app.bugs.repository import BugRepository
from app.utils.time import utc_now
from app.verifications.repository import VerificationRepository
from app.verifications.schemas import (
    CreateVerificationRequest,
    UpdateVerificationRequest,
    VerificationListResponse,
    VerificationResponse,
    VerificationSummaryResponse,
)


class VerificationService:
    """Business logic for bug verifications."""

    def __init__(
        self,
        verification_repository: VerificationRepository,
        bug_repository: BugRepository,
        db: Database,
    ) -> None:
        self.repository = verification_repository
        self.bug_repository = bug_repository
        self.users = db["users"]
        

    # ------------------------------------------------------------------
    # Helper methods
    # ------------------------------------------------------------------

    def _parse_bug_id(self, bug_id: str) -> ObjectId:
        """Convert a string bug ID into ObjectId."""

        try:
            return ObjectId(bug_id)
        except InvalidId as exc:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid bug ID.",
            ) from exc

    def _get_bug_or_404(self, bug_id: str) -> dict:
        """Ensure the bug exists."""

        bug = self.bug_repository.get_bug_by_id(self._parse_bug_id(bug_id))

        if bug is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Bug report not found.",
            )

        return bug

    def _get_username(self, user_id: ObjectId) -> str:
        """Return a user's username."""

        user = self.users.find_one({"_id": user_id}, {"name": 1})

        if user is None:
            return "Unknown User"

        return user["name"]

    def _build_verification_response(
        self,
        verification: dict,
    ) -> VerificationResponse:
        """Convert MongoDB document into VerificationResponse."""

        return VerificationResponse(
            _id=str(verification["_id"]),
            bug_id=str(verification["bug_id"]),
            user_id=str(verification["user_id"]),
            username=self._get_username(verification["user_id"]),
            verification_type=verification["verification_type"],
            app_version=verification["app_version"],
            screen_reader=verification.get("screen_reader"),
            screen_reader_version=verification.get("screen_reader_version"),
            device_model=verification.get("device_model"),
            created_at=verification["created_at"],
            updated_at=verification["updated_at"],
        )

    # ------------------------------------------------------------------
    # Public methods
    # ------------------------------------------------------------------

    def create_verification(
        self,
        bug_id: str,
        payload: CreateVerificationRequest,
        current_user_id: ObjectId,
    ) -> VerificationResponse:
        """Create a verification for a bug."""

        bug_object_id = self._parse_bug_id(bug_id)
        self._get_bug_or_404(bug_id)

        existing = self.repository.get_verification(
            bug_object_id,
            current_user_id,
        )

        if existing is not None:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="You have already verified this bug.",
            )

        now = utc_now()

        verification = {
            "bug_id": bug_object_id,
            "user_id": current_user_id,
            "verification_type": payload.verification_type.value,
            "app_version": payload.app_version,
            "screen_reader": (
                payload.screen_reader.value
                if payload.screen_reader
                else None
            ),
            "screen_reader_version": payload.screen_reader_version,
            "device_model": payload.device_model,
            "created_at": now,
            "updated_at": now,
        }

        verification_id = self.repository.create_verification(verification)

        created = self.repository.get_verification_by_id(verification_id)

        return self._build_verification_response(created)

    def update_verification(
        self,
        bug_id: str,
        payload: UpdateVerificationRequest,
        current_user_id: ObjectId,
    ) -> VerificationResponse:
        """Update the authenticated user's verification."""

        bug_object_id = self._parse_bug_id(bug_id)
        self._get_bug_or_404(bug_id)

        verification = self.repository.get_verification(
            bug_object_id,
            current_user_id,
        )

        if verification is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Verification not found.",
            )

        updates = payload.model_dump(exclude_none=True)

        if "verification_type" in updates:
            updates["verification_type"] = updates["verification_type"].value

        if "screen_reader" in updates:
            updates["screen_reader"] = updates["screen_reader"].value

        if updates:
            self.repository.update_verification(
                bug_id=bug_object_id,
                user_id=current_user_id,
                updates=updates,
                updated_at=utc_now(),
            )

            verification = self.repository.get_verification(
                bug_object_id,
                current_user_id,
            )

        return self._build_verification_response(verification)

    def delete_verification(
        self,
        bug_id: str,
        current_user_id: ObjectId,
    ) -> None:
        """Delete the authenticated user's verification."""

        bug_object_id = self._parse_bug_id(bug_id)
        self._get_bug_or_404(bug_id)

        verification = self.repository.get_verification(
            bug_object_id,
            current_user_id,
        )

        if verification is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Verification not found.",
            )

        self.repository.delete_verification(
            bug_id=bug_object_id,
            user_id=current_user_id,
        )

    def get_bug_verifications(
        self,
        bug_id: str,
    ) -> VerificationListResponse:
        """Return all community verifications for a bug."""

        bug_object_id = self._parse_bug_id(bug_id)
        self._get_bug_or_404(bug_id)

        verifications = self.repository.get_bug_verifications(
            bug_object_id,
        )

        return VerificationListResponse(
            verifications=[
                self._build_verification_response(verification)
                for verification in verifications
            ]
        )

    def get_verification_summary(
        self,
        bug_id: str,
    ) -> VerificationSummaryResponse:
        """Return verification statistics for a bug."""

        bug_object_id = self._parse_bug_id(bug_id)
        self._get_bug_or_404(bug_id)

        summary = self.repository.get_verification_summary(
            bug_object_id,
        )

        total = (
            summary["present"]
            + summary["fixed"]
            + summary["not_present"]
        )

        return VerificationSummaryResponse(
            present=summary["present"],
            fixed=summary["fixed"],
            not_present=summary["not_present"],
            total=total,
        )

    def get_my_verifications(
        self,
        current_user_id: ObjectId,
    ) -> VerificationListResponse:
        """Return all verifications created by the authenticated user."""

        verifications = self.repository.get_user_verifications(
            current_user_id,
        )

        return VerificationListResponse(
            verifications=[
                self._build_verification_response(verification)
                for verification in verifications
            ]
        )
