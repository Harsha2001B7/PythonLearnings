from fastapi import APIRouter, HTTPException, Query
from typing import List, Optional
from models import EmployeeCreate, EmployeeUpdate, EmployeeResponse, EmployeeListResponse
from service import employee_service
from exceptions import EmployeeNotFoundException, DuplicateEmailException, InvalidSalaryError

router = APIRouter(prefix="/employees", tags=["Employees"])

@router.post("/", response_model=EmployeeResponse, status_code=201)
def create_employee(employee_data: EmployeeCreate):
    try:
        return employee_service.create_employee(employee_data)
    except DuplicateEmailException as e:
        raise HTTPException(status_code=400, detail=str(e))
    except InvalidSalaryError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.get("/{employee_id}", response_model=EmployeeResponse)
def get_employee(employee_id: int):
    try:
        return employee_service.get_employee(employee_id)
    except EmployeeNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    
@router.get("/", response_model=EmployeeListResponse)
def get_all_employees(
        department: Optional[str] = Query(None, description="Filter by department"),
        page: int = Query(1, ge=1, description="Page number"),
        page_size: int = Query(10, ge=1, le=100, description="Number of records per page")
):
    return employee_service.get_all_employees(department, page, page_size)

@router.put("/{employee_id}", response_model=EmployeeResponse)
def update_employee(employee_id: int, update_data: EmployeeUpdate):
    try:
        return employee_service.update_employee(employee_id, update_data)
    except EmployeeNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    except DuplicateEmailException as e:
        raise HTTPException(status_code=400, detail=str(e))
    except InvalidSalaryError as e:
        raise HTTPException(status_code=400, detail=str(e))
@router.delete("/{employee_id}", status_code=204)
def delete_employee(employee_id: int):
    try:
        employee_service.delete_employee(employee_id)
    except EmployeeNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    