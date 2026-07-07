from fastapi import APIRouter
from app.api.v1.endpoints import cars, auth

api_router = APIRouter()
api_router.include_router(cars.router, prefix="/cars", tags=["cars"])
api_router.include_router(auth.router, prefix="/auth", tags=["auth"])
