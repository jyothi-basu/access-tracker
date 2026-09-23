"""Time helpers shared by application features."""

from datetime import datetime, timezone


def utc_now() -> datetime:
    """Return the current timezone-aware UTC time."""
    return datetime.now(timezone.utc)
