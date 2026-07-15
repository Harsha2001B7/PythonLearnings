from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.db.session import get_db
from app.models.models import User, Booking, ActivityLog
from app.schemas.schemas import UserResponse, UserStatusUpdate, ActivityLog as ActivityLogSchema
from app.api.dependencies import get_current_active_admin

router = APIRouter()

# Dependency override - require admin for all routes in this file
@router.get("/users", response_model=List[UserResponse])
def get_users(
    skip: int = 0,
    limit: int = 100,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    query = db.query(User)
    if search:
        query = query.filter(
            (User.email.contains(search)) |
            (User.first_name.contains(search)) |
            (User.last_name.contains(search))
        )
    return query.offset(skip).limit(limit).all()

@router.put("/users/{user_id}/status", response_model=UserResponse)
def update_user_status(
    user_id: int,
    status_in: UserStatusUpdate,
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    if user.id == admin.id:
        raise HTTPException(status_code=400, detail="Cannot change your own status")
        
    user.status = status_in.status
    
    # Log activity
    log = ActivityLog(
        user_id=admin.id,
        action="Update User Status",
        details=f"User ID {user_id} status updated to {status_in.status}",
        ip_address=request.client.host if request.client else None
    )
    db.add(log)
    
    db.commit()
    db.refresh(user)
    return user

@router.get("/bookings")
def get_admin_bookings(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    bookings = db.query(Booking).offset(skip).limit(limit).all()
    # Map models to JSON compatible output with nested items
    return [{
        "id": b.id,
        "userId": b.user_id,
        "vehicleId": b.vehicle_id,
        "startDate": b.start_date.isoformat() if b.start_date else None,
        "endDate": b.end_date.isoformat() if b.end_date else None,
        "totalPrice": b.total_price,
        "status": b.status,
        "createdAt": b.created_at.isoformat() if b.created_at else None,
        "user": {
            "id": b.user.id,
            "email": b.user.email,
            "firstName": b.user.first_name,
            "lastName": b.user.last_name,
            "phone": b.user.phone
        } if b.user else None,
        "vehicle": {
            "id": b.vehicle.id,
            "name": b.vehicle.name,
            "model": b.vehicle.model,
            "year": b.vehicle.year
        } if b.vehicle else None
    } for b in bookings]

@router.put("/bookings/{booking_id}/status")
def update_booking_status(
    booking_id: int,
    status_in: UserStatusUpdate, # We can reuse status schema
    request: Request,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
        
    old_status = booking.status
    booking.status = status_in.status
    
    # Log activity
    log = ActivityLog(
        user_id=admin.id,
        action="Update Booking Status",
        details=f"Booking ID {booking_id} status updated from {old_status} to {status_in.status}",
        ip_address=request.client.host if request.client else None
    )
    db.add(log)
    
    db.commit()
    return {"message": f"Booking status updated to {status_in.status}"}

@router.get("/activity-logs", response_model=List[ActivityLogSchema])
def get_activity_logs(
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    return db.query(ActivityLog).order_by(ActivityLog.created_at.desc()).offset(skip).limit(limit).all()
