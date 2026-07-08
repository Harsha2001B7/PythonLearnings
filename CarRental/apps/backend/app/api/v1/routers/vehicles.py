from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Any
import os
import shutil
import uuid

from app.api.dependencies import get_db, get_current_active_admin
from app.repositories.repositories import vehicle as vehicle_repo
from app.schemas.schemas import Vehicle, VehicleCreate
from app.core.config import settings
from app.models.models import VehicleImage

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
def create_vehicle(*, db: Session = Depends(get_db), vehicle_in: VehicleCreate, admin: Any = Depends(get_current_active_admin)):
    return vehicle_repo.create(db, obj_in=vehicle_in)

@router.put("/{id}", response_model=Vehicle)
def update_vehicle(*, db: Session = Depends(get_db), id: int, vehicle_in: VehicleCreate, admin: Any = Depends(get_current_active_admin)):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle_repo.update(db, db_obj=vehicle, obj_in=vehicle_in)

@router.delete("/{id}", response_model=Vehicle)
def delete_vehicle(*, db: Session = Depends(get_db), id: int, admin: Any = Depends(get_current_active_admin)):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle_repo.remove(db, id=id)

@router.post("/{vehicle_id}/upload-image")
def upload_vehicle_image(
    vehicle_id: int,
    file: UploadFile = File(...),
    image_type: str = Form("exterior"),
    db: Session = Depends(get_db),
    admin: Any = Depends(get_current_active_admin)
):
    vehicle = vehicle_repo.get(db, id=vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
        
    filename = file.filename
    
    upload_path = os.path.join(settings.UPLOADS_DIR, "vehicles", filename)
    
    try:
        with open(upload_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save image: {str(e)}")
        
    db_image = VehicleImage(
        vehicle_id=vehicle_id,
        image_url=f"/static/vehicles/{filename}",
        image_type=image_type
    )
    db.add(db_image)
    db.commit()
    db.refresh(db_image)
    return {
        "id": db_image.id,
        "vehicle_id": db_image.vehicle_id,
        "image_url": f"http://localhost:8000{db_image.image_url}",
        "image_type": db_image.image_type
    }

@router.delete("/images/{image_id}")
def delete_vehicle_image(
    image_id: int,
    db: Session = Depends(get_db),
    admin: Any = Depends(get_current_active_admin)
):
    img = db.query(VehicleImage).filter(VehicleImage.id == image_id).first()
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")
        
    filename = os.path.basename(img.image_url)
    file_path = os.path.join(settings.UPLOADS_DIR, "vehicles", filename)
    if os.path.exists(file_path):
        try:
            os.remove(file_path)
        except Exception:
            pass
            
    db.delete(img)
    db.commit()
    return {"message": "Image deleted successfully"}
