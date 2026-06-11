from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from enum import Enum
from datetime import datetime

class StudentCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100)
    roll_number: int = Field(..., gt=0)
    course_id: int = Field(..., gt=0, description="FK to courses table (1=Engineering, 2=Medicine etc.)")
    year: int = Field(..., ge=1, le=4)
    gpa: float = Field(..., ge=0.0, le=10.0)

class StudentUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    roll_number: Optional[int] = Field(None, gt=0)
    course_id: Optional[int] = Field(None, gt=0)
    year: Optional[int] = Field(None, ge=1, le=4)
    gpa: Optional[float] = Field(None, ge=0.0, le=10.0)

class StudentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)  # KEY LINE — enables ORM → Pydantic conversion
    id: int
    name: str
    roll_number: int
    course_id: int
    year: int
    gpa: float
    created_at: datetime

class StudentListResponse(BaseModel):
    total: int
    students: list[StudentResponse]
    page: int
    size: int
