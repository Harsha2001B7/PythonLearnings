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
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
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

    @app.get("/health", tags=["health"])
    async def health_check():
        return {"status": "ok", "message": "Service is healthy"}

    return app

app = create_app()
