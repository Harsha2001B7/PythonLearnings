from models.user import User
from schemas.auth_schema import(
    RegisterRequest, RegisterResponce
)

from repositories.user_repository import (
    get_by_username,
    get_by_email,
    create_user
)

from auth.password_handler import hash_password

from auth.password_handler import verify_password
from auth.jwt_handler import create_access_token

from exceptions.app_exceptions import (
    AppException
)


def register_user(db, request : RegisterRequest):
    username_exists = get_by_username(db, request.username)

    if username_exists:
        raise AppException(status_code=409, detail="Username already exists")
    
    email_exists = get_by_email(db, request.email)

    if email_exists:
        raise AppException(status_code=409, detail="Email already exists")
    
    hashed_password = hash_password(request.password)

    role_map = {
        "Employee" : 1,
        "Manager" : 2,
        "Admin" : 3
    }

    user = User(
        Username = request.username,
        Email = request.email,
        PasswordHash = hashed_password,
        RoleId = role_map[request.role]
    )

    return create_user(db, user)

def login(db, username, password):
    user = get_by_username(db, username)
    if user is None:
        return None
    is_valid = verify_password(password, user.PasswordHash)
    if not is_valid:
        return None
    token = create_access_token(
        {
            "user_id": user.Id,
            "username": user.Username,
            "role": user.role.RoleName
        }
    )
    return token
