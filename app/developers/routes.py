"""FastAPI routes for developer functionality."""

from bson import ObjectId
from fastapi import APIRouter, Depends
from pymongo.database import Database

from app.applications.repository import ApplicationRepository
from app.applications.service import ApplicationService
from app.bugs.repository import BugRepository
from app.bugs.service import BugService
from app.core.database import get_database
from app.core.dependencies import get_current_user_id
from app.developers.repository import DeveloperRepository
from app.developers.schemas import (
    CreateDeveloperResponseRequest,
    DeveloperApplicationSummary,
    DeveloperResponse,
    UpdateDeveloperResponseRequest,
)
from app.developers.service import DeveloperService

router = APIRouter()


def get_developer_service(
    db: Database = Depends(get_database),
) -> DeveloperService:
    """Create DeveloperService with its dependencies."""

    developer_repository = DeveloperRepository(db)
    bug_repository = BugRepository(db)
    application_repository = ApplicationRepository(db)

    application_service = ApplicationService(application_repository)
    bug_service = BugService(
        bug_repository=bug_repository,
        application_service=application_service,
        db=db,
    )

    return DeveloperService(
        repository=developer_repository,
        bug_repository=bug_repository,
        bug_service=bug_service,
        application_service=application_service,
        db=db,
    )


@router.get(
    "/applications",
    response_model=list[DeveloperApplicationSummary],
)
def get_developer_applications(
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: DeveloperService = Depends(get_developer_service),
) -> list[DeveloperApplicationSummary]:
    """Return applications represented by the authenticated developer."""
    return service.get_developer_applications(current_user_id)


@router.get(
    "/responses",
    response_model=list[DeveloperResponse],
)
def get_my_responses(
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: DeveloperService = Depends(get_developer_service),
) -> list[DeveloperResponse]:
    """Return responses created by the authenticated developer."""
    return service.get_my_responses(current_user_id)


@router.get(
    "/bugs/{bug_id}/responses",
    response_model=list[DeveloperResponse],
)
def get_bug_responses(
    bug_id: str,
    service: DeveloperService = Depends(get_developer_service),
) -> list[DeveloperResponse]:
    """Return all developer responses for a bug."""
    return service.get_bug_responses(bug_id)


@router.post(
    "/bugs/{bug_id}/responses",
    response_model=DeveloperResponse,
)
def create_response(
    bug_id: str,
    payload: CreateDeveloperResponseRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: DeveloperService = Depends(get_developer_service),
) -> DeveloperResponse:
    """Create a developer response for a bug."""
    return service.create_response(
        bug_id=bug_id,
        payload=payload,
        current_user_id=current_user_id,
    )


@router.patch(
    "/responses/{response_id}",
    response_model=DeveloperResponse,
)
def update_response(
    response_id: str,
    payload: UpdateDeveloperResponseRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: DeveloperService = Depends(get_developer_service),
) -> DeveloperResponse:
    """Update the authenticated developer's own response."""
    return service.update_response(
        response_id=response_id,
        payload=payload,
        current_user_id=current_user_id,
    )


@router.delete("/responses/{response_id}")
def delete_response(
    response_id: str,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: DeveloperService = Depends(get_developer_service),
) -> dict[str, str]:
    """Delete the authenticated developer's own response."""
    service.delete_response(
        response_id=response_id,
        current_user_id=current_user_id,
    )

    return {"detail": "Developer response deleted successfully."}