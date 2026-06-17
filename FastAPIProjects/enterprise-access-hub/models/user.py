from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from models.base import Base

class User(Base):
    __tablename__ = "Users"

    Id = Column(Integer, primary_key=True)
    Username = Column(String(100), unique=True, nullable=False)
    Email = Column(String(200), unique=True, nullable=False)
    PasswordHash = Column(String(500), nullable=False)
    RoleId = Column(Integer, ForeignKey("Roles.Id"), nullable=False)
    CreatedAt = Column(DateTime,server_default=func.now())
    role = relationship("Role",back_populates="users")