from sqlalchemy import Column, Integer, String
from models.base import Base

class Workspace(Base):
    __tablename__ = "Workspaces"

    Id = Column(Integer, primary_key=True)
    Title = Column(String(100), nullable=False)
    Description = Column(String(300))
    AccessLevel = Column(String(50),nullable=False)