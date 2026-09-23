"""FastAPI application factory and top-level health endpoint."""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.auth.routes import router as auth_router
from app.core.database import get_database, init_database_indexes


def create_app() -> FastAPI:
    """Create and configure the AccessTracker API application."""
    app = FastAPI(title="AccessTracker API", version="0.1.0")

    # Add CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])

    @app.on_event("startup")
    def startup_event() -> None:
        """Initialize MongoDB indexes when the application starts."""
        init_database_indexes(get_database())

    @app.get("/health")
    def health_check() -> dict[str, str]:
        """Return a lightweight liveness response."""
        return {"status": "ok"}

    return app


app = create_app()
