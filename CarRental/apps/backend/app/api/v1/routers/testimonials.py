from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Any
from app.api.dependencies import get_db, get_current_active_admin
from app.repositories.repositories import testimonial as testimonial_repo
from app.schemas.schemas import Testimonial, TestimonialBase

router = APIRouter()


@router.get("/", response_model=List[Testimonial])
def read_testimonials(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return testimonial_repo.get_multi(db, skip=skip, limit=limit)


@router.get("/{id}", response_model=Testimonial)
def read_testimonial(id: int, db: Session = Depends(get_db)):
    testimonial = testimonial_repo.get(db, id=id)
    if not testimonial:
        raise HTTPException(status_code=404, detail="Testimonial not found")
    return testimonial


@router.post("/", response_model=Testimonial)
def create_testimonial(
    *,
    db: Session = Depends(get_db),
    testimonial_in: TestimonialBase,
    admin: Any = Depends(get_current_active_admin),
):
    return testimonial_repo.create(db, obj_in=testimonial_in)


@router.put("/{id}", response_model=Testimonial)
def update_testimonial(
    *,
    db: Session = Depends(get_db),
    id: int,
    testimonial_in: TestimonialBase,
    admin: Any = Depends(get_current_active_admin),
):
    testimonial = testimonial_repo.get(db, id=id)
    if not testimonial:
        raise HTTPException(status_code=404, detail="Testimonial not found")
    return testimonial_repo.update(db, db_obj=testimonial, obj_in=testimonial_in)


@router.delete("/{id}", response_model=Testimonial)
def delete_testimonial(
    *,
    db: Session = Depends(get_db),
    id: int,
    admin: Any = Depends(get_current_active_admin),
):
    testimonial = testimonial_repo.get(db, id=id)
    if not testimonial:
        raise HTTPException(status_code=404, detail="Testimonial not found")
    return testimonial_repo.remove(db, id=id)
