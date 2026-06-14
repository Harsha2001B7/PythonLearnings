from repositories.student_repository import (
    get_all_students,
    get_teacher_students
)


def get_students(
    db,
    current_user
):

    if current_user["role"] == "Principal":
        return get_all_students(db)

    return get_teacher_students(
        db,
        current_user["user_id"]
    )