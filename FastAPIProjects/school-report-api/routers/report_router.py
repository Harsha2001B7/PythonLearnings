from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from database import get_db

from auth.dependencies import (
    get_current_user
)

from services.report_service import (
    get_students
)

from schemas.student_schema import (
    StudentResponse
)

router = APIRouter(
    prefix="/reports",
    tags=["Reports"]
)


@router.get(
    "/students",
    response_model=list[StudentResponse]
)
def student_report(
    db: Session = Depends(get_db),
    current_user=Depends(
        get_current_user  #first this gets executed because of dependencyt injection
    )
):

    return get_students(
        db,
        current_user
    )