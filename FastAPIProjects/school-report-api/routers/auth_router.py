from fastapi.security import OAuth2PasswordRequestForm
from fastapi import APIRouter,HTTPException,Depends


from sqlalchemy.orm import Session

from database import get_db

from schemas.auth_schema import (
    LoginRequest,
    TokenResponse
)

from services.auth_service import login

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post(
    "/login",
    response_model=TokenResponse
)
def login_user(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    token = login(
        db,
        form_data.username,
        form_data.password
    )

    if token is None:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials / User does not exits."
        )   

    return {
        "access_token": token,
        "token_type": "bearer"
    }