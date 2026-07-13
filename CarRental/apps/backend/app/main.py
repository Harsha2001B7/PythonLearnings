import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api.v1.router import api_router
from app.core.config import settings

def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.PROJECT_NAME,
        version="1.0.0",
        description="Luxury UAE Car Rental Platform API",
        docs_url="/docs",
        openapi_url="/openapi.json",
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

    # Ensure uploads directory exists
    os.makedirs(settings.UPLOADS_DIR, exist_ok=True)
    os.makedirs(os.path.join(settings.UPLOADS_DIR, "vehicles"), exist_ok=True)
    os.makedirs(os.path.join(settings.UPLOADS_DIR, "brands"), exist_ok=True)
    os.makedirs(os.path.join(settings.UPLOADS_DIR, "testimonials"), exist_ok=True)
    os.makedirs(os.path.join(settings.UPLOADS_DIR, "memberships"), exist_ok=True)
    
    app.mount("/static", StaticFiles(directory=settings.UPLOADS_DIR), name="static")

    app.include_router(api_router, prefix=settings.API_V1_STR)

    @app.on_event("startup")
    def run_migrations():
        import sqlite3
        db_path = settings.DATABASE_URI.replace("sqlite:///", "")
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        cursor.execute("PRAGMA table_info(users)")
        columns = [row[1] for row in cursor.fetchall()]
        if "google_sub" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN google_sub VARCHAR(255)")
        if "auth_provider" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN auth_provider VARCHAR(50) DEFAULT 'LOCAL'")
        if "avatar_url" not in columns:
            cursor.execute("ALTER TABLE users ADD COLUMN avatar_url VARCHAR(512)")
        conn.commit()
        conn.close()

    @app.get("/health", tags=["health"])
    async def health_check():
        return {"status": "ok", "message": "Service is healthy"}

    return app

app = create_app()
