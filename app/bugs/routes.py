"""FastAPI routes for accessibility bug reports."""

from bson import ObjectId
from fastapi import APIRouter, Depends, Query
from pymongo.database import Database

from app.applications.repository import ApplicationRepository
from app.applications.service import ApplicationService
from app.bugs.repository import BugRepository
from app.bugs.schemas import (
    BugListResponse,
    BugResponse,
    CreateBugRequest,
    UpdateBugRequest,
)
from app.bugs.service import BugService
from app.core.database import get_database
from app.core.dependencies import get_current_user_id

router = APIRouter()


def get_bug_service(
    db: Database = Depends(get_database),
) -> BugService:
    """Build the bug service with request-scoped dependencies."""

    application_service = ApplicationService(ApplicationRepository(db))
    bug_repository = BugRepository(db)

    return BugService(
        bug_repository=bug_repository,
        application_service=application_service,
    )


@router.post("", response_model=BugResponse)
def create_bug(
    payload: CreateBugRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: BugService = Depends(get_bug_service),
) -> BugResponse:
    """Create a new accessibility bug report."""
    return service.create_bug(payload, current_user_id)


@router.get("", response_model=BugListResponse)
def search_bugs(
    search: str | None = Query(default=None),
    application_name: str | None = Query(default=None),
    platform: str | None = Query(default=None),
    screen_reader: str | None = Query(default=None),
    severity: str | None = Query(default=None),
    service: BugService = Depends(get_bug_service),
) -> BugListResponse:
    """Browse and search accessibility bug reports."""
    return service.search_bugs(
        search=search,
        application_name=application_name,
        platform=platform,
        screen_reader=screen_reader,
        severity=severity,
    )


@router.get("/me", response_model=BugListResponse)
def get_my_bugs(
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: BugService = Depends(get_bug_service),
) -> BugListResponse:
    """Return bug reports created by the authenticated user."""
    return service.get_bugs_by_user(current_user_id)


@router.get("/{bug_id}", response_model=BugResponse)
def get_bug(
    bug_id: str,
    service: BugService = Depends(get_bug_service),
) -> BugResponse:
    """Return one bug report by its ID."""
    return service.get_bug_by_id(bug_id)


@router.patch("/{bug_id}", response_model=BugResponse)
def update_bug(
    bug_id: str,
    payload: UpdateBugRequest,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: BugService = Depends(get_bug_service),
) -> BugResponse:
    """Update an existing bug report owned by the authenticated user."""
    return service.update_bug(bug_id, payload, current_user_id)


@router.delete("/{bug_id}")
def delete_bug(
    bug_id: str,
    current_user_id: ObjectId = Depends(get_current_user_id),
    service: BugService = Depends(get_bug_service),
) -> dict[str, str]:
    """Delete an existing bug report owned by the authenticated user."""
    service.delete_bug(bug_id, current_user_id)
    return {"detail": "Bug report deleted successfully."}
