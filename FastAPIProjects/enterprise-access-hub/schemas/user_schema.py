from pydantic import BaseModel

class CurrentUserResponse(BaseModel):
    user_id: int
    username:str
    role:str