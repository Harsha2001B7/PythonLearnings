from pydantic import BaseModel
from typing import List, Optional

class CarBase(BaseModel):
    brand: str
    model: str
    year: int
    price_per_day: float
    image_url: str
    features: List[str] = []

class CarResponse(CarBase):
    id: str
