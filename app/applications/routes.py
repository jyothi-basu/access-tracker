"""HTTP routes for the Applications feature."""

from bson import ObjectId
from fastapi import APIRouter, Depends, Query
from pymongo.database import Database
from app.applications.repository import ApplicationRepository
from app.applications.schemas import (
    ApplicationResponse,
    CreateApplicationRequest,
)
from app.applications.service import ApplicationService
from app.core.database import get_database
from app.core.dependencies import get_current_user_id
from app.core.dependencies import require_roles
from app.core.constants import ROLE_ADMIN


router = APIRouter()

def get_application_service(
    db: Database = Depends(get_database),
) -> ApplicationService:
    """Build the application service with request-scoped dependencies."""
    return ApplicationService(ApplicationRepository(db))


@router.post("", response_model=ApplicationResponse)
def create_application(
    payload: CreateApplicationRequest,
    current_user_id: ObjectId = Depends(require_roles(ROLE_ADMIN)),
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationResponse:
    """Create a new application."""
    return service.create_application(payload, current_user_id)


@router.get("", response_model=list[ApplicationResponse])
def search_applications(
    search: str | None = Query(default=None, max_length=100),
    service: ApplicationService = Depends(get_application_service),
) -> list[ApplicationResponse]:
    """Search applications or list all applications."""
    return service.search_applications(search)


@router.get("/{application_id}", response_model=ApplicationResponse)
def get_application(
    application_id: str,
    service: ApplicationService = Depends(get_application_service),
) -> ApplicationResponse:
    """Return a single application by its ID."""
    return service.get_application(application_id)