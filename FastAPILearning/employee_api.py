from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, field_validator, EmailStr
from typing import List, Optional

# ============================================================
# APP SETUP
# ============================================================
# FastAPI application instance
# This creates the API and configures Swagger documentation.
# ============================================================

app = FastAPI(
    title="Employee API",
    description="A basic Employee Management API",
    version="1.0.0"
)

# ============================================================
# DATA MODELS (Pydantic Models)
# ============================================================
# These models define:
# 1. What data the API accepts
# 2. What data the API returns
# 3. Validation rules
# ============================================================


class EmployeeCreate(BaseModel):
    """
    Used when creating or updating an employee.

    Notice:
    - No ID field here.
    - The system generates IDs automatically.
    """

    name: str
    department: str
    salary: float
    email: EmailStr
    active: bool = True

    @field_validator("salary")
    @classmethod
    def salary_must_be_positive(cls, v):
        """
        Custom validation:
        Salary must be greater than zero.
        """
        if v <= 0:
                raise ValueError("Salary must be positive")
        return v

    @field_validator("name")
    @classmethod
    def name_must_not_be_empty(cls, v):
        """
        Prevent blank names.
        Also removes extra spaces.
        """
        if not v.strip():
            raise ValueError("Name cannot be empty")

        return v.strip()


class Employee(EmployeeCreate):
    """
    Full Employee model.

    Inherits everything from EmployeeCreate
    and adds an ID field.
    """

    id: int


class SalaryUpdate(BaseModel):
    """
    Used by PATCH endpoint.

    Only salary can be updated.
    """

    salary: float

    @field_validator("salary")
    @classmethod
    def salary_must_be_positive(cls, v):
        if v <= 0:
            raise ValueError("Salary must be positive")
        return v


# ============================================================
# IN-MEMORY DATABASE
# ============================================================
# This behaves like a temporary database table.
#
# Example:
# employees_db = [
#     Employee(...),
#     Employee(...),
# ]
#
# Data disappears whenever the application restarts.
# ============================================================

employees_db: List[Employee] = []

next_id = 1


# ============================================================
# HELPER FUNCTIONS
# ============================================================


def find_employee(employee_id: int) -> Optional[Employee]:
    """
    Search for an employee by ID.

    Returns:
        Employee object if found
        None if not found
    """

    for emp in employees_db:
        if emp.id == employee_id:
            return emp

    return None


def validate_unique_email(
    email: str,
    exclude_employee_id: Optional[int] = None
):
    """
    Business Rule:
    No two employees can have the same email.

    exclude_employee_id is used during UPDATE.

    Example:

    Employee 1:
        harsha@gmail.com

    Updating Employee 1:
        harsha@gmail.com

    This should be allowed.

    Therefore we skip the employee being updated.
    """

    for emp in employees_db:

        if emp.id == exclude_employee_id:
            continue

        if emp.email.lower() == email.lower():
            raise HTTPException(
                status_code=400,
                detail="Email already exists"
            )


# ============================================================
# ROOT ENDPOINT
# ============================================================

@app.get("/")
def root():
    """
    Health check endpoint.
    """

    return {
        "message": "Employee API",
        "version": "1.0.0",
        "total_employees": len(employees_db)
    }


# ============================================================
# CREATE EMPLOYEE
# ============================================================
# POST /employees
#
# SQL Equivalent:
# INSERT INTO Employees(...)
# ============================================================

@app.post(
    "/employees",
    response_model=Employee,
    status_code=201
)
def create_employee(employee_data: EmployeeCreate):

    global next_id

    # Email must be unique
    validate_unique_email(employee_data.email)

    # Create Employee object
    new_employee = Employee(
        id=next_id,
        **employee_data.model_dump()
    )

    # Save to "database"
    employees_db.append(new_employee)

    next_id += 1

    return new_employee


# ============================================================
# GET ALL EMPLOYEES
# ============================================================
# Supports:
# - department filter
# - minimum salary filter
# - pagination
#
# Examples:
#
# /employees
# /employees?department=IT
# /employees?min_salary=50000
# /employees?department=IT&min_salary=50000
# ============================================================

@app.get(
    "/employees",
    response_model=List[Employee]
)
def get_all_employees(
    department: Optional[str] = None,
    min_salary: Optional[float] = None,
    skip: int = 0,
    limit: int = 10
):

    result = employees_db.copy()

    # Department filter
    if department is not None:
        result = [
            e for e in result
            if e.department.lower() == department.lower()
        ]

    # Salary filter
    if min_salary is not None:
        result = [
            e for e in result
            if e.salary >= min_salary
        ]

    # Pagination
    return result[skip: skip + limit]


# ============================================================
# EMPLOYEE COUNT
# ============================================================

@app.get("/employees/count")
def get_employee_count():

    return {
        "count": len(employees_db)
    }


# ============================================================
# GET EMPLOYEE BY ID
# ============================================================
# SQL Equivalent:
#
# SELECT *
# FROM Employees
# WHERE Id = @employee_id
# ============================================================

@app.get(
    "/employees/{employee_id}",
    response_model=Employee
)
def get_employee(employee_id: int):

    emp = find_employee(employee_id)

    if emp is None:
        raise HTTPException(
            status_code=404,
            detail=f"Employee with ID {employee_id} not found"
        )

    return emp


# ============================================================
# UPDATE ENTIRE EMPLOYEE
# ============================================================
# PUT replaces the whole object.
#
# SQL Equivalent:
# UPDATE Employees
# ============================================================

@app.put(
    "/employees/{employee_id}",
    response_model=Employee
)
def update_employee(
    employee_id: int,
    employee_data: EmployeeCreate
):

    emp = find_employee(employee_id)

    if emp is None:
        raise HTTPException(
            status_code=404,
            detail=f"Employee with ID {employee_id} not found"
        )

    # Validate email uniqueness
    validate_unique_email(
        employee_data.email,
        exclude_employee_id=employee_id
    )

    employees_db.remove(emp)

    updated_employee = Employee(
        id=employee_id,
        **employee_data.model_dump()
    )

    employees_db.append(updated_employee)

    return updated_employee


# ============================================================
# DELETE EMPLOYEE
# ============================================================
# SQL Equivalent:
#
# DELETE FROM Employees
# WHERE Id = @employee_id
# ============================================================

@app.delete(
    "/employees/{employee_id}",
    status_code=204
)
def delete_employee(employee_id: int):

    emp = find_employee(employee_id)

    if emp is None:
        raise HTTPException(
            status_code=404,
            detail=f"Employee with ID {employee_id} not found"
        )

    employees_db.remove(emp)

    return None


# ============================================================
# UPDATE ONLY SALARY
# ============================================================
# PATCH updates only part of the object.
#
# SQL Equivalent:
#
# UPDATE Employees
# SET Salary = @salary
# WHERE Id = @employee_id
# ============================================================

@app.patch(
    "/employees/{employee_id}/salary",
    response_model=Employee
)
def update_salary(
    employee_id: int,
    salary_update: SalaryUpdate
):

    emp = find_employee(employee_id)

    if emp is None:
        raise HTTPException(
            status_code=404,
            detail=f"Employee with ID {employee_id} not found"
        )

    employees_db.remove(emp)

    updated_employee = Employee(
        id=emp.id,
        name=emp.name,
        department=emp.department,
        salary=salary_update.salary,
        email=emp.email,
        active=emp.active
    )

    employees_db.append(updated_employee)

    return updated_employee