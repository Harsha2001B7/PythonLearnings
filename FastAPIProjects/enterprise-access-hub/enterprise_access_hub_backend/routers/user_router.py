from fastapi import APIRouter,Depends
from auth.dependencies import get_current_user
from schemas.user_schema import (
    CurrentUserResponse
)

router = APIRouter(
    prefix="/api/v1/users",
    tags=["Users"]
)

@router.get(
    "/me",
    response_model=CurrentUserResponse
)
def get_me(
    current_user = Depends(
        get_current_user
    )
):
    return{
        "user_id": current_user.Id,
        "username": current_user.Username,
        "role": current_user.role.RoleName
    }