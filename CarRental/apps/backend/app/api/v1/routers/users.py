from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.models import User
from app.schemas.schemas import UserResponse, UserUpdate, UserPasswordUpdate
from app.api.dependencies import get_current_user
from app.core.security import get_password_hash, verify_password

router = APIRouter()

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user)):
    return current_user

@router.put("/me", response_model=UserResponse)
def update_me(
    user_in: UserUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    if user_in.first_name is not None:
        current_user.first_name = user_in.first_name
    if user_in.last_name is not None:
        current_user.last_name = user_in.last_name
    if user_in.phone is not None:
        current_user.phone = user_in.phone
    if user_in.country is not None:
        current_user.country = user_in.country
    if user_in.profile_image is not None:
        current_user.profile_image = user_in.profile_image
        
    db.commit()
    db.refresh(current_user)
    return current_user

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
    bookings = db.query(Booking).filter(Booking.user_id == current_user.id).all()
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
            "year": b.vehicle.year
        } if b.vehicle else None
    } for b in bookings]
