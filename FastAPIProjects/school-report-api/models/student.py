from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from models.user import Base


class Student(Base):
    __tablename__ = "Students"

    Id = Column(Integer, primary_key=True)

    StudentName = Column(String)

    Grade = Column(String)

    TeacherId = Column(
        Integer,
        ForeignKey("Users.Id")
    )

    teacher = relationship("User")