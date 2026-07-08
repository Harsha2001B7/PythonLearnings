from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.api.dependencies import get_db
from app.repositories.repositories import brand as brand_repo
from app.schemas.schemas import Brand, BrandCreate

router = APIRouter()

@router.get("/", response_model=List[Brand])
def read_brands(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return brand_repo.get_multi(db, skip=skip, limit=limit)

@router.get("/{id}", response_model=Brand)
def read_brand(id: int, db: Session = Depends(get_db)):
    brand = brand_repo.get(db, id=id)
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")
    return brand

@router.post("/", response_model=Brand)
def create_brand(*, db: Session = Depends(get_db), brand_in: BrandCreate):
    return brand_repo.create(db, obj_in=brand_in)

@router.put("/{id}", response_model=Brand)
def update_brand(*, db: Session = Depends(get_db), id: int, brand_in: BrandCreate):
    brand = brand_repo.get(db, id=id)
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")
    return brand_repo.update(db, db_obj=brand, obj_in=brand_in)

@router.delete("/{id}", response_model=Brand)
def delete_brand(*, db: Session = Depends(get_db), id: int):
    brand = brand_repo.get(db, id=id)
    if not brand:
        raise HTTPException(status_code=404, detail="Brand not found")
    return brand_repo.remove(db, id=id)
