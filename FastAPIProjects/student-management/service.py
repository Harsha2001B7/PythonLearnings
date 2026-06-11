from sqlalchemy.orm import Session
from repository import student_repo
from models import StudentCreate, StudentResponse, StudentListResponse, StudentUpdate
from exceptions import DuplicateRollNumberException, StudentNotFoundException
from typing import Optional


class StudentService:

    def create_student(self, db: Session, student_data: StudentCreate) -> StudentResponse:
        if student_repo.roll_number_exists(db, student_data.roll_number):
            raise DuplicateRollNumberException(student_data.roll_number)
        return student_repo.create(db, student_data)

    def get_all_students(
            self,
            db: Session,                        
            course_id: Optional[int] = None,    
            page: int = 1,
            page_size: int = 10
    ) -> StudentListResponse:
        skip = (page - 1) * page_size
        students, total = student_repo.get_all(db, course_id, skip, page_size)
        return StudentListResponse(
            total=total,
            students=students,
            page=page,
            size=page_size
        )

    def get_student_by_id(self, db: Session, student_id: int) -> StudentResponse:
        student = student_repo.get_by_id(db, student_id)
        if student is None:
            raise StudentNotFoundException(student_id)
        return student

    def update_student(
            self,
            db: Session,
            student_id: int,
            student_data: StudentUpdate
    ) -> StudentResponse:
        student = student_repo.get_by_id(db, student_id)
        if student is None:
            raise StudentNotFoundException(student_id)
        if student_data.roll_number is not None and student_repo.roll_number_exists(db, student_data.roll_number, student_id):
            raise DuplicateRollNumberException(student_data.roll_number)
        return student_repo.update(db, student_id, student_data)

    def delete_student(self, db: Session, student_id: int):
        student = student_repo.get_by_id(db, student_id)
        if student is None:
            raise StudentNotFoundException(student_id)
        student_repo.delete(db, student_id)

student_service = StudentService()