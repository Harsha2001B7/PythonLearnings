from fastapi import APIRouter, Query, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db        
from service import student_service
from models import StudentListResponse, StudentResponse, StudentCreate, StudentUpdate
from exceptions import DuplicateRollNumberException, StudentNotFoundException
from typing import Optional

router = APIRouter(prefix="/students", tags=["Students"])


@router.get("/", response_model=StudentListResponse)
def get_all_Students(
    db: Session = Depends(get_db),
    course_id: Optional[int] = Query(None, description="Filter by course id"),
    page: int = Query(1, description="Page Number"),
    page_size: int = Query(10, description="Students per Page")
):
    return student_service.get_all_students(db, course_id, page, page_size)


@router.post("/", response_model=StudentResponse, status_code=201)
def create_student(
    student: StudentCreate,
    db: Session = Depends(get_db)         
):
    try:
        return student_service.create_student(db, student)
    except DuplicateRollNumberException as e:
        raise HTTPException(status_code=409, detail=str(e))


@router.get("/{student_id}", response_model=StudentResponse)
def get_student(
    student_id: int,
    db: Session = Depends(get_db)
):
    try:
        return student_service.get_student_by_id(db, student_id)
    except StudentNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))


@router.patch("/{student_id}", response_model=StudentResponse)
def update_student(
    student_id: int,
    student_data: StudentUpdate,
    db: Session = Depends(get_db)
):
    try:
        return student_service.update_student(db, student_id, student_data)
    except StudentNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    except DuplicateRollNumberException as e:
        raise HTTPException(status_code=409, detail=str(e))


@router.delete("/{student_id}", status_code=204)
def delete_student(
    student_id: int,
    db: Session = Depends(get_db)
):
    try:
        student_service.delete_student(db, student_id)
    except StudentNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))


        # 8121971741