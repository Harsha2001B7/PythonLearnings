from pydantic import BaseModel, field_validator, Field
from typing import Optional
from datetime import date
from enum import Enum

class DepartmentEnum(str,Enum):
    engineering = "Engineering"
    hr = "HR"
    finance = "Finance"
    marketing = "Marketing"
    operations = "Operations"

class EmployeeCreate(BaseModel):
    name: str = Field(...,min_length=2,max_length=100, description="The full name of the employee")
    department: DepartmentEnum = Field(..., description="Depart must be one the following: Engineering, HR, Finance, Marketing, Operations")
    salary: float = Field(..., gt=0, description="The salary of the employee must be greater than 0")
    email: str = Field(..., description="The email of the employee must be a valid email address")
    hire_date: Optional[date] = None

    @field_validator('email')
    def validate_email(cls,v):
        if '@' not in v:
            raise ValueError('Invalid email address')
        return v.lower()
    
class EmployeeUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    department: Optional[DepartmentEnum] = None
    salary: Optional[float] = Field(None, gt=0)
    email: Optional[str] = None

class EmployeeResponse(BaseModel):
    id: int
    name: str
    department: DepartmentEnum
    salary: float
    email: str
    hire_date: Optional[date] = None

    class Config:
        orm_mode = True

class EmployeeListResponse(BaseModel):
    total: int
    employees: list[EmployeeResponse]
    page: int
    page_size: int