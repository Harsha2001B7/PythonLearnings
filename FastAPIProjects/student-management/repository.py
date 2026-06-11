from typing import Optional
from sqlalchemy.orm import Session
from db_models import Student
from models import StudentCreate, StudentResponse, StudentUpdate


class StudentRepository:

    def create(self, db: Session, student_data: StudentCreate) -> StudentResponse:
        new_student = Student(**student_data.model_dump())
        db.add(new_student)    
        db.commit()             
        db.refresh(new_student)  
        return StudentResponse.model_validate(new_student)

    def get_by_id(self, db: Session, student_id: int) -> Optional[StudentResponse]:
        student = db.query(Student).filter(Student.id == student_id).first()
        if student is None:
            return None
        return StudentResponse.model_validate(student)

    def get_all(
        self,
        db: Session,
        course_id: Optional[int] = None,
        skip: int = 0,
        limit: int = 10
    ) -> tuple[list[StudentResponse], int]:
        query = db.query(Student)
        if course_id is not None:
            query = query.filter(Student.course_id == course_id)
        total = query.count()
        students = query.order_by(Student.id).offset(skip).limit(limit).all()
        return [StudentResponse.model_validate(s) for s in students], total

    def update(
        self,
        db: Session,
        student_id: int,
        student_data: StudentUpdate
    ) -> Optional[StudentResponse]:
        student = db.query(Student).filter(Student.id == student_id).first()
        if student is None:
            return None
        updated_fields = student_data.model_dump(exclude_none=True)
        for key, value in updated_fields.items():
            setattr(student, key, value) 
        db.commit()            
        db.refresh(student)
        return StudentResponse.model_validate(student)

    def delete(self, db: Session, student_id: int) -> bool:
        student = db.query(Student).filter(Student.id == student_id).first()
        if student is None:
            return False
        db.delete(student)  
        db.commit()       
        return True

    def roll_number_exists(
        self,
        db: Session,
        roll_number: int,
        exclude_id: Optional[int] = None
    ) -> bool:
        query = db.query(Student).filter(Student.roll_number == roll_number)
        if exclude_id is not None:
            query = query.filter(Student.id != exclude_id)
        return query.first() is not None

student_repo = StudentRepository()