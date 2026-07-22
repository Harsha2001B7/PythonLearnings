from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime, timezone

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
        created_at=datetime.now(timezone.utc),
    )
    db.add(db_booking)
    db.commit()
    db.refresh(db_booking)

    # ── Trigger Push Notifications ──
    try:
        from app.services.notification_service import NotificationService
        v_img = vehicle.images[0].image_url if vehicle.images else None

        # 1. Notify User if authenticated
        if current_user:
            NotificationService.send_to_user(
                db=db,
                user_id=current_user.id,
                title="🏎️ Booking Requested",
                message=f"Your reservation request for {vehicle.name} (Ref #{db_booking.id}) has been received! Our team will contact you shortly.",
                notification_type="booking_created",
                booking_id=db_booking.id,
                vehicle_id=vehicle.id,
                vehicle_name=vehicle.name,
                vehicle_image=v_img,
                booking_reference=f"#FV-{db_booking.id}",
                action_route="/vehicle",
            )
        # 2. Notify Admins with clean customer name and dates (no email)
        if current_user:
            user_label = f"{current_user.first_name or ''} {current_user.last_name or ''}".strip() or current_user.email
        else:
            user_label = "Guest Customer"

        start_str = db_booking.start_date.strftime("%d %b") if db_booking.start_date else "N/A"
        end_str = db_booking.end_date.strftime("%d %b %Y") if db_booking.end_date else "N/A"

        NotificationService.send_to_admins(
            db=db,
            title=f"🏎️ New Booking: {user_label}",
            message=f"Car: {vehicle.name}\nDates: {start_str} – {end_str} · Ref #{db_booking.id}",
            notification_type="admin_new_booking",
            booking_id=db_booking.id,
            vehicle_id=vehicle.id,
            vehicle_name=vehicle.name,
            vehicle_image=v_img,
            booking_reference=f"#FV-{db_booking.id}",
            action_route="/admin",
        )
    except Exception as exc:
        import logging
        logging.getLogger(__name__).error(f"Error triggering push notification in create_booking: {exc}")

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


