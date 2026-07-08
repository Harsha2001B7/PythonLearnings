from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime, date

from app.db.session import get_db
from app.models.models import Vehicle, Booking, User, Testimonial, Category, Brand
from app.api.dependencies import get_current_active_admin

router = APIRouter()

@router.get("/stats")
def get_dashboard_stats(
    db: Session = Depends(get_db),
    admin: User = Depends(get_current_active_admin)
):
    total_vehicles = db.query(Vehicle).count()
    available_vehicles = db.query(Vehicle).filter(Vehicle.available == True).count()
    booked_vehicles = db.query(Vehicle).filter(Vehicle.available == False).count()
    
    total_users = db.query(User).count()
    
    # Today's bookings
    today_start = datetime.combine(date.today(), datetime.min.time())
    today_bookings = db.query(Booking).filter(Booking.created_at >= today_start).count()
    
    total_testimonials = db.query(Testimonial).count()
    total_categories = db.query(Category).count()
    total_brands = db.query(Brand).count()
    
    # Calculate revenue (sum of total_price of completed/confirmed bookings)
    total_revenue = db.query(Booking).filter(
        Booking.status.in_(["confirmed", "completed"])
    ).with_entities(Booking.total_price).all()
    revenue_sum = sum(item[0] for item in total_revenue if item[0] is not None)

    return {
        "totalVehicles": total_vehicles,
        "availableVehicles": available_vehicles,
        "bookedVehicles": booked_vehicles,
        "totalUsers": total_users,
        "todayBookings": today_bookings,
        "totalTestimonials": total_testimonials,
        "totalCategories": total_categories,
        "totalBrands": total_brands,
        "monthlyRevenue": revenue_sum
    }
