from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime

from app.db.session import get_db
from app.models.models import Booking, Vehicle, User
from app.schemas.schemas import BookingCreate, BookingResponse
from app.api.dependencies import get_current_user, get_optional_user, get_current_active_admin

router = APIRouter()


@router.post("/", response_model=BookingResponse, status_code=status.HTTP_201_CREATED)
def create_booking(
    booking_in: BookingCreate,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_user),
):
    """Create a new booking. Called immediately when user clicks Book via WhatsApp.
    Stores with status 'pending'. user_id is attached if user is logged in, else null."""
    vehicle = db.query(Vehicle).filter(Vehicle.id == booking_in.vehicle_id).first()
    if not vehicle:
        raise HTTPException(status_code=404, detail="Vehicle not found")

    db_booking = Booking(
        vehicle_id=booking_in.vehicle_id,
        user_id=current_user.id if current_user else None,
        start_date=booking_in.start_date,
        end_date=booking_in.end_date,
        total_price=booking_in.total_price,
        status="pending",
        created_at=datetime.utcnow(),
    )
    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)
    return db_booking


@router.get("/my", response_model=List[BookingResponse])
def get_my_bookings(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all bookings for the currently authenticated user."""
    return (
        db.query(Booking)
        .filter(Booking.user_id == current_user.id)
        .order_by(Booking.created_at.desc())
        .all()
    )


@router.get("/", response_model=List[BookingResponse])
def get_all_bookings(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Admin: get all bookings."""
    return db.query(Booking).order_by(Booking.created_at.desc()).offset(skip).limit(limit).all()


@router.patch("/{booking_id}/status", response_model=BookingResponse)
def update_booking_status(
    booking_id: int,
    new_status: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_active_admin),
):
    """Admin: update booking status (confirmed, cancelled, completed)."""
    booking = db.query(Booking).filter(Booking.id == booking_id).first()
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    allowed = {"pending", "confirmed", "cancelled", "completed"}
    if new_status not in allowed:
        raise HTTPException(status_code=400, detail=f"Status must be one of {allowed}")
    booking.status = new_status
    db.commit()
    db.refresh(booking)
    return booking
