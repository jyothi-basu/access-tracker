"""FastAPI routes for bug verifications."""

from bson import ObjectId
from fastapi import APIRouter, Depends
from pymongo.database import Database

from app.bugs.repository import BugRepository
from app.core.database import get_database
from app.core.dependencies import get_current_user_id
from app.verifications.repository import VerificationRepository
from app.verifications.schemas import (
    CreateVerificationRequest,
    UpdateVerificationRequest,
    VerificationListResponse,
    VerificationResponse,
    VerificationSummaryResponse,
)
from app.verifications.service import VerificationService

router = APIRouter()


def get_verification_service(
    db: Database = Depends(get_database),
) -> VerificationService:
    """Build the verification service with its dependencies."""

    verification_repository = VerificationRepository(db)
    bug_repository = BugRepository(db)

    return VerificationService(
        verification_repository=verification_repository,
        bug_repository=bug_repository,
        db=db,
    )


@router.post(
    "/bugs/{bug_id}/verifications",
    response_model=VerificationResponse,
)
def create_verification(
    bug_id: str,
    payload: CreateVerificationRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: VerificationService = Depends(get_verification_service),
) -> VerificationResponse:
    """Create a verification for a bug."""
    return service.create_verification(
        bug_id=bug_id,
        payload=payload,
        current_user_id=current_user_id,
    )


@router.patch(
    "/bugs/{bug_id}/verifications",
    response_model=VerificationResponse,
)
def update_verification(
    bug_id: str,
    payload: UpdateVerificationRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: VerificationService = Depends(get_verification_service),
) -> VerificationResponse:
    """Update the authenticated user's verification."""
    return service.update_verification(
        bug_id=bug_id,
        payload=payload,
        current_user_id=current_user_id,
    )


@router.delete("/bugs/{bug_id}/verifications")
def delete_verification(
    bug_id: str,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: VerificationService = Depends(get_verification_service),
) -> dict[str, str]:
    """Delete the authenticated user's verification."""
    service.delete_verification(
        bug_id=bug_id,
        current_user_id=current_user_id,
    )

    return {"detail": "Verification deleted successfully."}


@router.get(
    "/bugs/{bug_id}/verifications",
    response_model=VerificationListResponse,
)
def get_bug_verifications(
    bug_id: str,
    service: VerificationService = Depends(get_verification_service),
) -> VerificationListResponse:
    """Return all community verifications for a bug."""
    return service.get_bug_verifications(bug_id)


@router.get(
    "/bugs/{bug_id}/verifications/summary",
    response_model=VerificationSummaryResponse,
)
def get_verification_summary(
    bug_id: str,
    service: VerificationService = Depends(get_verification_service),
) -> VerificationSummaryResponse:
    """Return community verification statistics for a bug."""
    return service.get_verification_summary(bug_id)


@router.get(
    "/verifications/me",
    response_model=VerificationListResponse,
)
def get_my_verifications(
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: VerificationService = Depends(get_verification_service),
) -> VerificationListResponse:
    """Return all verifications created by the authenticated user."""
    return service.get_my_verifications(current_user_id)
