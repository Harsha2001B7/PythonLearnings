from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import declarative_base

Base = declarative_base()


class User(Base):
    __tablename__ = "Users"

    Id = Column(Integer, primary_key=True)
    Username = Column(String)
    PasswordHash = Column(String)
    Role = Column(String)