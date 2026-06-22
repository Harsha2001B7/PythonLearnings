from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.task import Task
from app.models.user import User
from app.schemas.task import TaskCreate
from app.schemas.task import TaskResponse

router = APIRouter(prefix="/tasks", tags=["tasks"])


@router.post("", response_model=TaskResponse, status_code=201)
def create_task(task_in: TaskCreate, db: Session = Depends(get_db)):

    user = db.query(User).filter(User.id == task_in.user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    task = Task(
        user_id=task_in.user_id,
        title=task_in.title,
        description=task_in.description,
        priority=task_in.priority,
        status=task_in.status,
    )

    db.add(task)
    db.commit()
    db.refresh(task)

    return task


@router.get("", response_model=list[TaskResponse])
def list_tasks(db: Session = Depends(get_db)):

    return db.query(Task).all()
