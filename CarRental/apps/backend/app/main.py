import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api.v1.router import api_router
from app.core.config import settings

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger(__name__)


def _run_sqlite_migrations() -> None:
    """Apply incremental SQLite schema migrations on startup.

    This guard exists only for SQLite. When migrated to PostgreSQL on Azure,
    use Alembic migrations instead and remove this function.
    """
    if not settings.DATABASE_URI.startswith("sqlite"):
        return

    import sqlite3
    db_path = settings.DATABASE_URI.replace("sqlite:///", "")
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in cursor.fetchall()]
        altered = False
        if "google_sub" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN google_sub VARCHAR(255)")
            altered = True
        if "auth_provider" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN auth_provider VARCHAR(50) DEFAULT 'LOCAL'")
            altered = True
        if "avatar_url" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN avatar_url VARCHAR(512)")
            altered = True
        if altered:
            conn.commit()
            logger.info("SQLite schema migration applied successfully.")
        conn.close()
    except Exception as exc:
        logger.error("SQLite migration failed: %s", exc)


@asynccontextmanager
async def lifespan(app: FastAPI):
    # ── Startup ────────────────────────────────────────────────
    logger.info("Starting %s in %s environment", settings.PROJECT_NAME, settings.ENVIRONMENT)

    # Ensure upload directories exist
    for sub in ("vehicles", "brands", "testimonials", "memberships"):
        os.makedirs(os.path.join(settings.UPLOADS_DIR, sub), exist_ok=True)

    _run_sqlite_migrations()

    yield
    # ── Shutdown ───────────────────────────────────────────────
    logger.info("Shutting down %s", settings.PROJECT_NAME)


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version="1.0.0",
        description="Luxury UAE Car Rental Platform API",
        docs_url="/docs" if settings.ENVIRONMENT != "production" else None,
        openapi_url="/openapi.json" if settings.ENVIRONMENT != "production" else None,
        lifespan=lifespan,
    )

    # Set up CORS
    cors_origins = list(settings.BACKEND_CORS_ORIGINS)
    if settings.FRONTEND_URL and settings.FRONTEND_URL not in cors_origins:
        cors_origins.append(settings.FRONTEND_URL)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in cors_origins],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.mount("/static", StaticFiles(directory=settings.UPLOADS_DIR), name="static")
    app.include_router(api_router, prefix=settings.API_V1_STR)

    @app.get("/health", tags=["health"])
    async def health_check():
        return {"status": "ok", "service": settings.PROJECT_NAME, "environment": settings.ENVIRONMENT}

    return app


app = create_app()
