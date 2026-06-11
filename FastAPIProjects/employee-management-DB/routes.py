from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from database import get_db
from schemas import EmployeeCreate, EmployeeUpdate, EmployeeResponse
from repository import employee_repo
 
router = APIRouter(prefix='/employees', tags=['Employees'])
 
@router.post('/', response_model=EmployeeResponse, status_code=201)
def create_employee(
    employee: EmployeeCreate,
    db: Session = Depends(get_db)   # FastAPI calls get_db() and injects the session
):
    if employee_repo.email_exists(db, employee.email):
        raise HTTPException(status_code=409, detail='Email already registered')
    return employee_repo.create(db, employee)
 
@router.get('/{employee_id}', response_model=EmployeeResponse)
def get_employee(employee_id: int, db: Session = Depends(get_db)):
    emp = employee_repo.get_by_id(db, employee_id)
    if not emp:
        raise HTTPException(status_code=404, detail=f'Employee {employee_id} not found')
    return emp
 
@router.patch('/{employee_id}', response_model=EmployeeResponse)
def update_employee(
    employee_id: int,
    update_data: EmployeeUpdate,
    db: Session = Depends(get_db)
):
    if update_data.email:
        if employee_repo.email_exists(db, update_data.email, exclude_id=employee_id):
            raise HTTPException(status_code=409, detail='Email already in use')
    emp = employee_repo.update(db, employee_id, update_data)
    if not emp:
        raise HTTPException(status_code=404, detail='Employee not found')
    return emp
 
@router.delete('/{employee_id}', status_code=204)
def delete_employee(employee_id: int, db: Session = Depends(get_db)):
    deleted = employee_repo.delete(db, employee_id)
    if not deleted:
        raise HTTPException(status_code=404, detail='Employee not found')
