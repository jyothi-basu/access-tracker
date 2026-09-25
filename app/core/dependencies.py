"""FastAPI dependencies for extracting authenticated request context."""

from collections.abc import Callable

import jwt
from bson import ObjectId
from bson.errors import InvalidId
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pymongo.database import Database

from app.core.database import get_database
from app.core.security import decode_token


bearer_scheme = HTTPBearer(auto_error=False)

def get_current_user_id(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
) -> ObjectId:
    """Validate a bearer access token and return its user ID."""
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing access token")

    try:
        payload = decode_token(credentials.credentials)
    except jwt.PyJWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid access token") from exc

    if payload.get("type") != "access":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token type")

    try:
        return ObjectId(payload["sub"])
    except (InvalidId, KeyError) as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token subject") from exc


def require_roles(*allowed_roles: str) -> Callable:
    """Require the authenticated user to have one of the allowed roles."""

    def role_dependency(
        current_user_id: ObjectId = Depends(get_current_user_id),
        db: Database = Depends(get_database),
    ) -> ObjectId:
        user = db["users"].find_one(
            {"_id": current_user_id},
            {"role": 1},
        )

        if user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found.",
            )

        if user["role"] not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to perform this action.",
            )

        return current_user_id

    return role_dependency


def get_current_user(
    current_user_id: ObjectId = Depends(get_current_user_id),
    db: Database = Depends(get_database),
) -> dict:
    """Return the authenticated user's document."""

    user = db["users"].find_one({"_id": current_user_id})

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found.",
        )

    return user