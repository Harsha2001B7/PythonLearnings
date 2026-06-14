from pydantic import BaseModel
from pydantic import ConfigDict


class StudentResponse(BaseModel):

    Id: int
    StudentName: str
    Grade: str

    model_config = ConfigDict(
        from_attributes=True
    )