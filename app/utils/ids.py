"""Identifier conversion helpers."""

from bson import ObjectId


def to_object_id(value: str) -> ObjectId:
    """Convert a string into a MongoDB ObjectId or raise its validation error."""
    return ObjectId(value)
