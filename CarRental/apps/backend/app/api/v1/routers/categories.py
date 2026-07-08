from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.api.dependencies import get_db
from app.repositories.repositories import category as category_repo
from app.schemas.schemas import Category, CategoryCreate

router = APIRouter()

@router.get("/", response_model=List[Category])
def read_categories(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return category_repo.get_multi(db, skip=skip, limit=limit)

@router.get("/{id}", response_model=Category)
def read_category(id: int, db: Session = Depends(get_db)):
    category = category_repo.get(db, id=id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category

@router.post("/", response_model=Category)
def create_category(*, db: Session = Depends(get_db), category_in: CategoryCreate):
    return category_repo.create(db, obj_in=category_in)

@router.put("/{id}", response_model=Category)
def update_category(*, db: Session = Depends(get_db), id: int, category_in: CategoryCreate):
    category = category_repo.get(db, id=id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category_repo.update(db, db_obj=category, obj_in=category_in)

@router.delete("/{id}", response_model=Category)
def delete_category(*, db: Session = Depends(get_db), id: int):
    category = category_repo.get(db, id=id)
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")
    return category_repo.remove(db, id=id)
