from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from schemas.auth_schema import(
    RegisterRequest,
    RegisterResponce
)
from services.auth_service import register_user
from fastapi.security import OAuth2PasswordRequestForm
from schemas.auth_schema import (
    LoginRequest,
    TokenResponse
)
from services.auth_service import login
from exceptions.app_exceptions import (
    AppException
)


router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

@router.post(
    "/register",
    response_model=RegisterResponce
)
def register(
    request: RegisterRequest,
    db: Session = Depends(get_db)
):
    user = register_user(db, request)
    return {
        "id" : user.Id,
        "username": user.Username,
        "email" : user.Email,
        "role" : request.role
    }
    
@router.post(
    "/login",
    response_model= TokenResponse
)
def login_user(
    request: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    token = login(
        db,
        request.username,
        request.password
    )
    if token is None:
        raise AppException(status_code=401, detail="Invalid credentials")
    return {
        "access_token": token,
        "token_type": "bearer"
    }