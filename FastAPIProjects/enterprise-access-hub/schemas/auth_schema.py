from pydantic import BaseModel, EmailStr

class RegisterRequest(BaseModel):
    username : str
    email : EmailStr
    password: str
    role : str

class RegisterResponce(BaseModel):
    id: int
    username : str
    email: str
    role:str

class LoginRequest(BaseModel):
    username : str
    password : str

class TokenResponse(BaseModel):
    access_token : str
    token_type : str