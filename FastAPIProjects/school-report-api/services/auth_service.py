from repositories.user_repository import get_by_username

from auth.password_handler import verify_password

from auth.jwt_handler import create_access_token


def login(
    db,
    username,
    password
):

    user = get_by_username(
        db,
        username
    )

    if not user:
        return None

    if not verify_password(
        password,
        user.PasswordHash
    ):
        return None

    token = create_access_token(
        {
            "user_id": user.Id,
            "username": user.Username,
            "role": user.Role
        }
    )

    return token