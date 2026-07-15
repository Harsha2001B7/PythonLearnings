from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Any
from app.api.dependencies import get_db, get_current_active_admin
from app.repositories.repositories import faq as faq_repo
from app.schemas.schemas import FAQ, FAQBase

router = APIRouter()


@router.get("/", response_model=List[FAQ])
def read_faqs(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return faq_repo.get_multi(db, skip=skip, limit=limit)


@router.get("/{id}", response_model=FAQ)
def read_faq(id: int, db: Session = Depends(get_db)):
    faq = faq_repo.get(db, id=id)
    if not faq:
        raise HTTPException(status_code=404, detail="FAQ not found")
    return faq


@router.post("/", response_model=FAQ)
def create_faq(
    *,
    db: Session = Depends(get_db),
    faq_in: FAQBase,
    admin: Any = Depends(get_current_active_admin),
):
    return faq_repo.create(db, obj_in=faq_in)


@router.put("/{id}", response_model=FAQ)
def update_faq(
    *,
    db: Session = Depends(get_db),
    id: int,
    faq_in: FAQBase,
    admin: Any = Depends(get_current_active_admin),
):
    faq = faq_repo.get(db, id=id)
    if not faq:
        raise HTTPException(status_code=404, detail="FAQ not found")
    return faq_repo.update(db, db_obj=faq, obj_in=faq_in)


@router.delete("/{id}", response_model=FAQ)
def delete_faq(
    *,
    db: Session = Depends(get_db),
    id: int,
    admin: Any = Depends(get_current_active_admin),
):
    faq = faq_repo.get(db, id=id)
    if not faq:
        raise HTTPException(status_code=404, detail="FAQ not found")
    return faq_repo.remove(db, id=id)
