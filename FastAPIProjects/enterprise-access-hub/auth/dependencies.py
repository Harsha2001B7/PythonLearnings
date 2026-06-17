from fastapi import Depends,HTTPException
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from database import get_db
from auth.jwt_handler import decode_access_token
from repositories.user_repository import get_by_username
from exceptions.app_exceptions import (
    AppException
)


oauth2_schema = OAuth2PasswordBearer(
    tokenUrl="/api/v1/auth/login"
)

def get_current_user(
        token : str = Depends(oauth2_schema),
        db: Session = Depends(get_db)
):
    payload = decode_access_token(
        token
    )
    if payload is None:
        raise AppException(
            status_code = 401,
            detail = "Invalid token"
        )
    user = get_by_username(
        db,
        payload["username"]
    )
    if user is None:
        raise AppException(
            status_code=401,
            detail = "User not found"
        )
    return user

def require_employee(
        current_user = Depends(get_current_user)
):
    return current_user

def require_manager(
        current_user=Depends(
            get_current_user
        )
):
    if current_user.role.RoleName not in [
        "Manager",
        "Admin"
    ]:
        raise AppException(
            status_code=403,
            detail = "Access denied"
        )
    return current_user

def require_admin(
        current_user=Depends(
            get_current_user
        )
):
    if current_user.role.RoleName != "Admin":
        raise AppException(
            status_code=403,
            detail = "Access denied"
        )
    return current_user