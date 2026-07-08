from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Any
from app.api.dependencies import get_db
from app.repositories.repositories import vehicle as vehicle_repo
from app.schemas.schemas import Vehicle, VehicleCreate

router = APIRouter()

@router.get("/", response_model=List[Vehicle])
def read_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return vehicle_repo.get_multi(db, skip=skip, limit=limit)

@router.get("/featured", response_model=List[Vehicle])
def read_featured_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehicles = db.query(vehicle_repo.model).filter(vehicle_repo.model.featured == True).offset(skip).limit(limit).all()
    return vehicles

@router.get("/popular", response_model=List[Vehicle])
def read_popular_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehicles = db.query(vehicle_repo.model).filter(vehicle_repo.model.is_popular == True).offset(skip).limit(limit).all()
    return vehicles

@router.get("/{id}", response_model=Vehicle)
def read_vehicle(id: int, db: Session = Depends(get_db)):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle

@router.post("/", response_model=Vehicle)
def create_vehicle(*, db: Session = Depends(get_db), vehicle_in: VehicleCreate):
    return vehicle_repo.create(db, obj_in=vehicle_in)

@router.put("/{id}", response_model=Vehicle)
def update_vehicle(*, db: Session = Depends(get_db), id: int, vehicle_in: VehicleCreate):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle_repo.update(db, db_obj=vehicle, obj_in=vehicle_in)

@router.delete("/{id}", response_model=Vehicle)
def delete_vehicle(*, db: Session = Depends(get_db), id: int):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle_repo.remove(db, id=id)
