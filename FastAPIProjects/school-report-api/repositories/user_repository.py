from models.user import User


def get_by_username(db, username):

    return (
        db.query(User)
        .filter(
            User.Username == username
        )
        .first()
    )