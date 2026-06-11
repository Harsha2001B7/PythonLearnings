from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base


class Course(Base):
    __tablename__ = "courses"

    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(50),  nullable=False, unique=True)
    description = Column(String(200), nullable=True)

    students = relationship('Student', back_populates='course')


class Student(Base):
    __tablename__ = "students"

    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(100), nullable=False)
    roll_number = Column(Integer,     nullable=False, unique=True, index=True)
    course_id   = Column(Integer,     ForeignKey('courses.id'), nullable=False)
    year        = Column(Integer,     nullable=False)
    gpa         = Column(Float,       nullable=False)
    created_at  = Column(DateTime,    server_default=func.now())

    course = relationship('Course', back_populates='students')