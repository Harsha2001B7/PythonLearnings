from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.user import User
from app.schemas.user import UserCreate
from app.schemas.user import UserResponse

router = APIRouter(prefix="/users", tags=["users"])


@router.post("", response_model=UserResponse, status_code=201)
def create_user(user_in: UserCreate, db: Session = Depends(get_db)):

    existing = db.query(User).filter(User.email == user_in.email).first()

    if existing:
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(name=user_in.name, email=user_in.email)

    db.add(user)
    db.commit()
    db.refresh(user)

    return user


@router.get("", response_model=list[UserResponse])
def list_users(db: Session = Depends(get_db)):

    return db.query(User).all()
