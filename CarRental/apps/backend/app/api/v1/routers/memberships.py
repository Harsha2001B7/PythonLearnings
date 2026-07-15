from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.models.models import MembershipTier
from app.schemas.schemas import MembershipTier as MembershipTierSchema

router = APIRouter()


@router.get("/", response_model=List[MembershipTierSchema])
def get_memberships(db: Session = Depends(get_db)):
    return db.query(MembershipTier).all()
