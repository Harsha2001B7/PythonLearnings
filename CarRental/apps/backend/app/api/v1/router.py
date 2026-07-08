from fastapi import APIRouter

from app.api.v1.routers import (
    home, vehicles, categories, brands, faqs, testimonials, offers,
    settings, memberships, auth, users, admin, dashboard
)

api_router = APIRouter()
api_router.include_router(home.router, prefix="/home", tags=["home"])
api_router.include_router(vehicles.router, prefix="/vehicles", tags=["vehicles"])
api_router.include_router(categories.router, prefix="/categories", tags=["categories"])
api_router.include_router(brands.router, prefix="/brands", tags=["brands"])
api_router.include_router(faqs.router, prefix="/faqs", tags=["faqs"])
api_router.include_router(testimonials.router, prefix="/testimonials", tags=["testimonials"])
api_router.include_router(offers.router, prefix="/offers", tags=["offers"])
api_router.include_router(settings.router, prefix="/settings", tags=["settings"])
api_router.include_router(memberships.router, prefix="/memberships", tags=["memberships"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
api_router.include_router(users.router, prefix="/users", tags=["users"])
api_router.include_router(admin.router, prefix="/admin", tags=["admin"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
