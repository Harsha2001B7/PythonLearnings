from models.student import Student


def get_all_students(db):

    return (
        db.query(Student)
        .all()
    )


def get_teacher_students(
    db,
    teacher_id
):

    return (
        db.query(Student)
        .filter(
            Student.TeacherId == teacher_id
        )
        .all()
    )