from fastapi import APIRouter
from fastapi import Depends
from sqlalchemy import func
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.task import Task
from app.schemas.dashboard import DashboardResponse

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardResponse)
def get_dashboard(db: Session = Depends(get_db)):

    total_tasks = db.query(func.count(Task.id)).scalar()

    pending_tasks = (
        db.query(func.count(Task.id))
        .filter(Task.status == "pending")
        .scalar()
    )

    completed_tasks = (
        db.query(func.count(Task.id))
        .filter(Task.status == "completed")
        .scalar()
    )

    return DashboardResponse(
        total_tasks=total_tasks,
        pending_tasks=pending_tasks,
        completed_tasks=completed_tasks,
    )
