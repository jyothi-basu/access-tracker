"""Pydantic schemas for accessibility bug reports."""

from datetime import datetime
from enum import Enum

from bson import ObjectId
from pydantic import BaseModel, ConfigDict, Field


# ---------- Enums ----------

class Platform(str, Enum):
    android = "android"
    ios = "ios"
    windows = "windows"
    macos = "macos"
    linux = "linux"
    web = "web"


class ScreenReader(str, Enum):
    nvda = "nvda"
    talkback = "talkback"
    voiceover = "voiceover"
    jaws = "jaws"
    narrator = "narrator"
    orca = "orca"
    other = "other"


class Severity(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"


# ---------- Request Schemas ----------

class CreateBugRequest(BaseModel):
    application_name: str = Field(min_length=1, max_length=100)
    platform: Platform
    app_version: str = Field(min_length=1, max_length=50)

    title: str = Field(min_length=5, max_length=150)
    actual_behavior: str = Field(min_length=10, max_length=5000)
    expected_behavior: str = Field(min_length=10, max_length=5000)

    screen_reader: ScreenReader

    severity: Severity = Severity.medium
    steps_to_reproduce: str | None = Field(default=None, max_length=5000)
    screen_reader_version: str | None = Field(default=None, max_length=50)
    device_model: str | None = Field(default=None, max_length=100)


class UpdateBugRequest(BaseModel):
    title: str | None = Field(default=None, min_length=5, max_length=150)
    actual_behavior: str | None = Field(default=None, min_length=10, max_length=5000)
    expected_behavior: str | None = Field(default=None, min_length=10, max_length=5000)

    app_version: str | None = Field(default=None, min_length=1, max_length=50)
    severity: Severity | None = None
    steps_to_reproduce: str | None = Field(default=None, max_length=5000)
    screen_reader_version: str | None = Field(default=None, max_length=50)
    device_model: str | None = Field(default=None, max_length=100)


# ---------- Response Schemas ----------

class BugResponse(BaseModel):

    id: str = Field(alias="_id")

    application_id: str
    application_name: str

    platform: Platform
    app_version: str

    title: str
    actual_behavior: str
    expected_behavior: str

    screen_reader: ScreenReader
    severity: Severity

    steps_to_reproduce: str | None = None
    screen_reader_version: str | None = None
    device_model: str | None = None

    reporter_username: str
    created_by: str
    created_at: datetime
    updated_at: datetime


class BugListResponse(BaseModel):
    bugs: list[BugResponse]
