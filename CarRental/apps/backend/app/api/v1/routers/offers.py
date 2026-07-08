from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.api.dependencies import get_db
from app.repositories.repositories import offer as offer_repo
from app.schemas.schemas import Offer, OfferBase

router = APIRouter()

@router.get("/", response_model=List[Offer])
def read_offers(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return offer_repo.get_multi(db, skip=skip, limit=limit)

@router.get("/{id}", response_model=Offer)
def read_offer(id: int, db: Session = Depends(get_db)):
    offer = offer_repo.get(db, id=id)
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
    return offer

@router.post("/", response_model=Offer)
def create_offer(*, db: Session = Depends(get_db), offer_in: OfferBase):
    return offer_repo.create(db, obj_in=offer_in)

@router.put("/{id}", response_model=Offer)
def update_offer(*, db: Session = Depends(get_db), id: int, offer_in: OfferBase):
    offer = offer_repo.get(db, id=id)
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
    return offer_repo.update(db, db_obj=offer, obj_in=offer_in)

@router.delete("/{id}", response_model=Offer)
def delete_offer(*, db: Session = Depends(get_db), id: int):
    offer = offer_repo.get(db, id=id)
    if not offer:
        raise HTTPException(status_code=404, detail="Offer not found")
    return offer_repo.remove(db, id=id)
