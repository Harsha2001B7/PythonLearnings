from datetime import datetime

from pydantic import BaseModel
from pydantic import ConfigDict


class TaskCreate(BaseModel):

    user_id: int

    title: str

    description: str

    priority: str

    status: str


class TaskResponse(BaseModel):

    model_config = ConfigDict(from_attributes=True)

    id: int

    user_id: int

    title: str

    description: str

    priority: str

    status: str

    created_at: datetime
