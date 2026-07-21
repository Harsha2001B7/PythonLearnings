from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List, Any
import os
import shutil
import uuid

from app.api.dependencies import get_db, get_current_active_admin, get_optional_user
from app.repositories.repositories import vehicle as vehicle_repo
from app.schemas.schemas import Vehicle, VehicleCreate
from app.core.config import settings
from app.models.models import VehicleImage

router = APIRouter()

@router.get("/", response_model=List[Vehicle])
def read_vehicles(
    skip: int = 0, 
    limit: int = 100, 
    db: Session = Depends(get_db), 
    current_user: Any = Depends(get_optional_user)
):
    is_admin = bool(current_user and current_user.role_rel and current_user.role_rel.name == "Admin")
    return vehicle_repo.get_multi(db, skip=skip, limit=limit, include_inactive=is_admin)

@router.get("/featured", response_model=List[Vehicle])
def read_featured_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehicles = db.query(vehicle_repo.model).filter(
        vehicle_repo.model.featured.is_(True),
        vehicle_repo.model.available.is_(True)
    ).offset(skip).limit(limit).all()
    return vehicles

@router.get("/popular", response_model=List[Vehicle])
def read_popular_vehicles(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    vehicles = db.query(vehicle_repo.model).filter(
        vehicle_repo.model.is_popular.is_(True),
        vehicle_repo.model.available.is_(True)
    ).offset(skip).limit(limit).all()
    return vehicles

@router.get("/{id}", response_model=Vehicle)
def read_vehicle(id: int, db: Session = Depends(get_db)):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
    return vehicle

@router.post("/", response_model=Vehicle)
def create_vehicle(*, db: Session = Depends(get_db), vehicle_in: VehicleCreate, admin: Any = Depends(get_current_active_admin)):
    # Check if a vehicle with the same name already exists under the selected brand
    existing = db.query(vehicle_repo.model).filter(
        vehicle_repo.model.brand_id == vehicle_in.brand_id,
        vehicle_repo.model.name.ilike(vehicle_in.name.strip())
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"A vehicle with the name '{vehicle_in.name}' already exists under this brand."
        )
    if vehicle_in.quantity <= 0:
        vehicle_in.available = False
    return vehicle_repo.create(db, obj_in=vehicle_in)

@router.put("/{id}", response_model=Vehicle)
def update_vehicle(*, db: Session = Depends(get_db), id: int, vehicle_in: VehicleCreate, admin: Any = Depends(get_current_active_admin)):
    vehicle = vehicle_repo.get(db, id=id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
        
    # Check duplicate on update if name or brand is changed
    existing = db.query(vehicle_repo.model).filter(
        vehicle_repo.model.brand_id == vehicle_in.brand_id,
        vehicle_repo.model.name.ilike(vehicle_in.name.strip()),
        vehicle_repo.model.id != id
    ).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Another vehicle with the name '{vehicle_in.name}' already exists under this brand."
        )

    if vehicle_in.quantity <= 0:
        vehicle_in.available = False
        
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
    import time
    vehicle = vehicle_repo.get(db, id=vehicle_id)
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")
        
    # Generate clean, readable filename based on Brand & Vehicle Name
    brand_name = vehicle.brand_rel.name if vehicle.brand_rel else "vehicle"
    raw_ext = os.path.splitext(file.filename)[1].lower()
    ext = raw_ext if raw_ext in (".jpg", ".jpeg", ".png", ".webp") else ".jpg"
    
    clean_raw = f"{brand_name}-{vehicle.name}".lower()
    clean_slug = "".join([c if c.isalnum() else "-" for c in clean_raw])
    clean_slug = "-".join(filter(None, clean_slug.split("-")))
    
    if image_type == "thumbnail":
        filename = f"{clean_slug}-thumbnail{ext}"
    else:
        timestamp = int(time.time())
        filename = f"{clean_slug}-{image_type}-{timestamp}{ext}"
    
    # If this is a thumbnail, delete all existing thumbnails first to keep only one
    if image_type == "thumbnail":
        old_thumbnails = db.query(VehicleImage).filter(
            VehicleImage.vehicle_id == vehicle_id,
            VehicleImage.image_type == "thumbnail"
        ).all()
        for old_img in old_thumbnails:
            old_filename = os.path.basename(old_img.image_url)
            old_file_path = os.path.join(settings.UPLOADS_DIR, "vehicles", old_filename)
            if os.path.exists(old_file_path):
                try:
                    os.remove(old_file_path)
                except Exception:
                    pass
            db.delete(old_img)
            
    upload_path = os.path.join(settings.UPLOADS_DIR, "vehicles", filename)
    
    try:
        with open(upload_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save image: {str(e)}")
        
    image_relative_url = f"/static/vehicles/{filename}"
    
    db_image = VehicleImage(
        vehicle_id=vehicle_id,
        image_url=image_relative_url,
        image_type=image_type
    )
    db.add(db_image)
    
    # Also update vehicle's primary_image if uploading a thumbnail
    if image_type == "thumbnail":
        vehicle.primary_image = image_relative_url
        db.add(vehicle)
        
    db.commit()
    db.refresh(db_image)
    return {
        "id": db_image.id,
        "vehicle_id": db_image.vehicle_id,
        "image_url": f"{settings.BACKEND_URL}{db_image.image_url}",
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
