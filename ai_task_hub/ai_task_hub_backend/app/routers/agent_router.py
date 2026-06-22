from fastapi import APIRouter
from fastapi import Depends
from sqlalchemy.orm import Session

from app.database.db import get_db
from app.models.task import Task
from app.schemas.agent import AgentSummaryRequest
from app.schemas.agent import AgentSummaryResponse
from app.services.summary_service import build_task_summary

router = APIRouter(prefix="/agent", tags=["agent"])


@router.post("/summary", response_model=AgentSummaryResponse)
def summarize_tasks(
    request: AgentSummaryRequest,
    db: Session = Depends(get_db),
):

    tasks = db.query(Task).all()
    summary = build_task_summary(tasks)

    return AgentSummaryResponse(
        question=request.question,
        summary=summary,
    )
