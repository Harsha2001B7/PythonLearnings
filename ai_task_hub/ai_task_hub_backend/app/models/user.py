from datetime import datetime

from sqlalchemy import Column
from sqlalchemy import DateTime
from sqlalchemy import Integer
from sqlalchemy import String

from app.database.db import Base


class User(Base):

    __tablename__ = "users"

    id = Column(Integer, primary_key=True)

    name = Column(String)

    email = Column(String, unique=True)

    created_at = Column(DateTime, default=datetime.utcnow)
