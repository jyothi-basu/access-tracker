"""Pydantic schemas for developer applications and responses."""

from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field

from app.applications.schemas import Platform


class DeveloperApplicationStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"


class CreateDeveloperResponseRequest(BaseModel):
    response: str = Field(min_length=1)


class UpdateDeveloperResponseRequest(BaseModel):
    response: str = Field(min_length=1)


class DeveloperResponse(BaseModel):
    id: str = Field(alias="_id")
    bug_id: str
    application_id: str
    developer_id: str
    developer_username: str
    response: str
    created_at: datetime
    updated_at: datetime


class DeveloperApplicationSummary(BaseModel):
    application_id: str
    application_name: str
    platform: Platform
    bug_count: int
