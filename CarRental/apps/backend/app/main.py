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

        cursor.execute("PRAGMA table_info(vehicles)")
        v_columns = [row[1] for row in cursor.fetchall()]
        if "quantity" not in v_columns:
            cursor.execute("ALTER TABLE vehicles ADD COLUMN quantity INTEGER DEFAULT 1")
            cursor.execute("UPDATE vehicles SET quantity = 1 WHERE quantity IS NULL OR quantity = 0")
            altered = True
        
        # Ensure brand logos are seeded
        logo_map = {
            "mitsubishi": "/static/brands/mitsubishiBrandLogo.png",
            "nissan": "/static/brands/nissanBrandLogo.png",
            "mg": "/static/brands/mgBrandLogo.png",
            "kia": "/static/brands/kiaBrandLogo.png",
            "suzuki": "/static/brands/suzukiBrandLogo.png",
            "mazda": "/static/brands/mazdaBrandLogo.png",
            "toyota": "/static/brands/toyotaBrandLogo.png",
            "dodge": "/static/brands/dodgeBrandLogo.png",
            "hyundai": "/static/brands/hyundaiBrandLogo.png",
            "kaiyi": "/static/brands/Kaiyi_logo.png"
        }
        for slug, logo in logo_map.items():
            cursor.execute("UPDATE brands SET logo_url = ? WHERE slug = ? AND logo_url IS NULL", (logo, slug))
            altered = True

        if altered:
            conn.commit()
            logger.info("SQLite schema migration and brand seeding applied successfully.")
        conn.close()
    except Exception as exc:
        logger.error("SQLite migration/seeding failed: %s", exc)


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
    if settings.ENVIRONMENT == "development":
        cors_origins = ["*"]
    else:
        cors_origins = [str(origin) for origin in settings.BACKEND_CORS_ORIGINS]
        if settings.FRONTEND_URL and settings.FRONTEND_URL not in cors_origins:
            cors_origins.append(settings.FRONTEND_URL)

    app.add_middleware(
        CORSMiddleware,
        allow_origins=cors_origins,
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
