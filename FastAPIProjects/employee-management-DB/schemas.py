from pydantic import BaseModel, Field, field_validator
from typing import Optional
from datetime import date
 
class EmployeeCreate(BaseModel):
    name:          str   = Field(..., min_length=2)
    email:         str
    salary:        float = Field(..., gt=0)
    department_id: int   = Field(..., gt=0)
    hire_date:     Optional[date] = None
 
    @field_validator('email')
    def email_lowercase(cls, v):
        return v.lower()
 
class EmployeeUpdate(BaseModel):
    name:          Optional[str]   = None
    salary:        Optional[float] = Field(None, gt=0)
    department_id: Optional[int]   = None
    is_active:     Optional[bool]  = None
 
class DepartmentResponse(BaseModel):
    id:   int
    name: str
    class Config:
        from_attributes = True
 
class EmployeeResponse(BaseModel):
    id:            int
    name:          str
    email:         str
    salary:        float
    hire_date:     Optional[date]
    is_active:     bool
    department:    Optional[DepartmentResponse] = None
    class Config:
        from_attributes = True    
