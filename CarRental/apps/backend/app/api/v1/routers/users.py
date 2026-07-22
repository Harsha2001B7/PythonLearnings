import os
import time
import shutil
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.models import User
from app.schemas.schemas import UserResponse, UserMeResponse, UserUpdate, UserPasswordUpdate
from app.api.dependencies import get_current_user
from app.core.security import get_password_hash, verify_password
from app.core.config import settings

router = APIRouter()

def _format_user_me_response(user: User):
    role_name = user.role_rel.name if user.role_rel else "User"
    permissions = ["admin"] if role_name == "Admin" else ["customer"]
    first_name = user.first_name or ""
    last_name = user.last_name or ""
    full_name = f"{first_name} {last_name}".strip() or user.email
    avatar = user.profile_image or user.avatar_url
    if avatar and not avatar.startswith("http://") and not avatar.startswith("https://"):
        avatar = f"{settings.BACKEND_URL.rstrip('/')}{avatar}" if avatar.startswith('/') else f"{settings.BACKEND_URL.rstrip('/')}/{avatar}"

    return {
        "id": user.id,
        "name": full_name,
        "email": user.email,
        "role": role_name,
        "permissions": permissions,
        "avatar": avatar,
        "created_at": user.created_at,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "phone": user.phone,
        "country": user.country,
        "status": user.status,
        "is_verified": user.is_verified,
        "role_id": user.role_id,
    }

@router.get("/me", response_model=UserMeResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return _format_user_me_response(current_user)

@router.put("/me", response_model=UserMeResponse)
def update_me(
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if user_in.first_name is not None:
        current_user.first_name = user_in.first_name.strip()
    if user_in.last_name is not None:
        current_user.last_name = user_in.last_name.strip()
    if user_in.phone is not None:
        current_user.phone = user_in.phone.strip()
    if user_in.country is not None:
        current_user.country = user_in.country.strip()
    if user_in.profile_image is not None:
        current_user.profile_image = user_in.profile_image.strip()
        
    db.commit()
    db.refresh(current_user)
    return _format_user_me_response(current_user)

@router.post("/me/upload-avatar", response_model=UserMeResponse)
def upload_avatar(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    raw_ext = os.path.splitext(file.filename)[1].lower() if file.filename else ".jpg"
    ext = raw_ext if raw_ext in (".jpg", ".jpeg", ".png", ".webp") else ".jpg"
    
    avatars_dir = os.path.join(settings.UPLOADS_DIR, "avatars")
    os.makedirs(avatars_dir, exist_ok=True)
    
    filename = f"user_{current_user.id}_{int(time.time())}{ext}"
    upload_path = os.path.join(avatars_dir, filename)
    
    # Delete old avatar file from disk if present
    if current_user.profile_image and "/static/avatars/" in current_user.profile_image:
        old_filename = os.path.basename(current_user.profile_image)
        old_file_path = os.path.join(avatars_dir, old_filename)
        if os.path.exists(old_file_path):
            try:
                os.remove(old_file_path)
            except Exception:
                pass

    try:
        with open(upload_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save avatar image: {str(e)}")

    relative_url = f"/static/avatars/{filename}"
    current_user.profile_image = relative_url
    current_user.avatar_url = f"{settings.BACKEND_URL.rstrip('/')}{relative_url}"
    
    db.commit()
    db.refresh(current_user)
    return _format_user_me_response(current_user)

@router.put("/me/password")
def change_password(
    pass_in: UserPasswordUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if not verify_password(pass_in.old_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Incorrect old password"
        )
    current_user.password_hash = get_password_hash(pass_in.new_password)
    db.commit()
    return {"message": "Password changed successfully"}

@router.get("/me/bookings")
def get_my_bookings(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    from app.models.models import Booking
    bookings = db.query(Booking).filter(Booking.user_id == current_user.id).order_by(Booking.created_at.desc(), Booking.id.desc()).all()
    return [{
        "id": b.id,
        "vehicleId": b.vehicle_id,
        "startDate": b.start_date.isoformat() if b.start_date else None,
        "endDate": b.end_date.isoformat() if b.end_date else None,
        "totalPrice": b.total_price,
        "status": b.status,
        "createdAt": b.created_at.isoformat() if b.created_at else None,
        "vehicle": {
            "id": b.vehicle.id,
            "name": b.vehicle.name,
            "model": b.vehicle.model,
            "year": b.vehicle.year,
            "primaryImage": (f"{settings.BACKEND_URL}{b.vehicle.images[0].image_url}" if b.vehicle.images and not b.vehicle.images[0].image_url.startswith('http') else (b.vehicle.images[0].image_url if b.vehicle.images else None))
        } if b.vehicle else None
    } for b in bookings]
