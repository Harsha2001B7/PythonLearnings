from datetime import datetime

from sqlalchemy import Column
from sqlalchemy import DateTime
from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import String

from app.database.db import Base


class Task(Base):

    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True)

    user_id = Column(Integer, ForeignKey("users.id"))

    title = Column(String)

    description = Column(String)

    priority = Column(String)

    status = Column(String)

    created_at = Column(DateTime, default=datetime.utcnow)
