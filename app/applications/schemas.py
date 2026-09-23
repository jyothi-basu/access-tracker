"""Pydantic schemas for the Applications feature."""

from enum import Enum

from pydantic import BaseModel, Field, field_validator


class Platform(str, Enum):
    """Supported application platforms."""

    ANDROID = "android"
    IOS = "ios"
    WINDOWS = "windows"
    WEB = "web"
    LINUX = "linux"
    MACOS = "macos"


class CreateApplicationRequest(BaseModel):
    """Request body for creating a new application."""

    display_name: str = Field(
        ...,
        min_length=2,
        max_length=100,
        description="User-facing application name.",
    )
    platform: Platform

    @field_validator("display_name")
    @classmethod
    def validate_display_name(cls, value: str) -> str:
        """Trim extra whitespace from the application name."""
        cleaned = " ".join(value.strip().split())

        if not cleaned:
            raise ValueError("Application name cannot be empty.")

        return cleaned


class ApplicationResponse(BaseModel):
    """Application returned to the client."""

    id: str
    display_name: str
    platform: Platform