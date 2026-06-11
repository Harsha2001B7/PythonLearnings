from sqlalchemy import Column, Integer, String, Float, Boolean, Date, DateTime
from sqlalchemy import ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base
 
class Department(Base):
    __tablename__ = "departments" 
 
    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(50),  nullable=False, unique=True)
    description = Column(String(200), nullable=True)
    created_at  = Column(DateTime,    server_default=func.now())

    employees = relationship('Employee', back_populates='department')
 
class Employee(Base):
    __tablename__ = "employees"  
 
    id            = Column(Integer, primary_key=True, index=True)
    name          = Column(String(100), nullable=False)
    email         = Column(String(150), nullable=False, unique=True, index=True)
    salary        = Column(Float,       nullable=False)
    department_id = Column(Integer,     ForeignKey('departments.id'), nullable=False)
    hire_date     = Column(Date,         nullable=False)
    is_active     = Column(Boolean,      default=True)
    created_at    = Column(DateTime,     server_default=func.now())
    updated_at    = Column(DateTime,     server_default=func.now(), onupdate=func.now())
 
    department = relationship('Department', back_populates='employees')
