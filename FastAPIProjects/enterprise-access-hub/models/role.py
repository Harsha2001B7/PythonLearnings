from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from models.base import Base

class Role(Base):
    __tablename__ = "Roles"

    Id = Column(Integer, primary_key=True)
    RoleName = Column(String(50), unique=True, nullable=False)
    users = relationship("User", back_populates="role")