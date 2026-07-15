from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import Dict, Any
from app.api.dependencies import get_db
from app.repositories.repositories import vehicle, category, brand, testimonial, faq

router = APIRouter()

@router.get("/")
def get_home_data(db: Session = Depends(get_db)) -> Dict[str, Any]:
    return {
        "featured_vehicles": db.query(vehicle.model).filter(
            vehicle.model.featured.is_(True),
            vehicle.model.available.is_(True)
        ).limit(6).all(),
        "categories": category.get_multi(db, limit=10),
        "brands": brand.get_multi(db, limit=10),
        "testimonials": testimonial.get_multi(db, limit=5),
        "faqs": faq.get_multi(db, limit=5)
    }
