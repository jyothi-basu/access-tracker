"""Pydantic schemas for bug verifications."""

from app.bugs.schemas import ScreenReader
from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field


# ---------- Enums ----------

class VerificationType(str, Enum):
    present = "present"
    fixed = "fixed"
    not_present = "not_present"


# ---------- Request Schemas ----------

class CreateVerificationRequest(BaseModel):
    verification_type: VerificationType

    app_version: str = Field(min_length=1, max_length=50)

    screen_reader: ScreenReader | None = None
    screen_reader_version: str | None = Field(default=None, max_length=50)
    device_model: str | None = Field(default=None, max_length=100)


class UpdateVerificationRequest(BaseModel):
    verification_type: VerificationType | None = None

    app_version: str | None = Field(default=None, min_length=1, max_length=50)

    screen_reader: ScreenReader | None = None    
    screen_reader_version: str | None = Field(default=None, max_length=50)
    device_model: str | None = Field(default=None, max_length=100)


# ---------- Response Schemas ----------

class VerificationResponse(BaseModel):
    id: str = Field(alias="_id")

    bug_id: str
    user_id: str
    username: str

    verification_type: VerificationType

    app_version: str
    screen_reader: ScreenReader | None = None
    screen_reader_version: str | None = None
    device_model: str | None = None

    created_at: datetime
    updated_at: datetime


class VerificationListResponse(BaseModel):
    verifications: list[VerificationResponse]


class VerificationSummaryResponse(BaseModel):
    present: int
    fixed: int
    not_present: int
    total: int
