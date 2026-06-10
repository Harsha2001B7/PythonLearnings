from pydantic import BaseModel

class PostResponce(BaseModel):
    title: str
    content: str