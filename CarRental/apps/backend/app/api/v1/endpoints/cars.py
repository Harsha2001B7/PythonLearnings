from fastapi import APIRouter, HTTPException
from typing import List
from app.domain.schemas.car import CarResponse

router = APIRouter()

MOCK_CARS = [
    {"id": "1", "brand": "Aston Martin", "model": "Vantage GT", "year": 2024, "price_per_day": 420, "image_url": "https://images.pexels.com/photos/20131973/pexels-photo-20131973.jpeg", "features": ["Electric GT", "3.1s 0-60", "2 Seats"]},
    {"id": "2", "brand": "Bentley", "model": "Continental S", "year": 2024, "price_per_day": 310, "image_url": "https://images.pexels.com/photos/29566862/pexels-photo-29566862.jpeg", "features": ["V8 Petrol", "4 Seats", "Auto"]},
    {"id": "3", "brand": "Honda", "model": "Ridgeline Sport", "year": 2023, "price_per_day": 280, "image_url": "https://images.pexels.com/photos/5288744/pexels-photo-5288744.jpeg", "features": ["Hybrid", "5 Seats", "Performance SUV"]},
]

@router.get("/", response_model=List[CarResponse])
async def get_cars():
    return MOCK_CARS

@router.get("/{car_id}", response_model=CarResponse)
async def get_car(car_id: str):
    for car in MOCK_CARS:
        if car["id"] == car_id:
            return car
    raise HTTPException(status_code=404, detail="Car not found")
