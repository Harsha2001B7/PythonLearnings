from pydantic import BaseModel, ConfigDict
from typing import List, Optional, Any
from datetime import datetime, date

class ORMModel(BaseModel):
    model_config = ConfigDict(from_attributes=True)

class BrandBase(BaseModel):
    name: str
    slug: str
    logo_url: Optional[str] = None

class BrandCreate(BrandBase):
    pass

class Brand(BrandBase, ORMModel):
    id: int

class CategoryBase(BaseModel):
    name: str
    slug: str

class CategoryCreate(CategoryBase):
    pass

class Category(CategoryBase, ORMModel):
    id: int

class VehicleImageBase(BaseModel):
    image_url: str
    image_type: Optional[str] = None

class VehicleImage(VehicleImageBase, ORMModel):
    id: int
    vehicle_id: int

class VehiclePricingBase(BaseModel):
    daily: float
    weekly: float
    monthly: float
    excess_per_km: Optional[float] = None
    kms_daily: Optional[int] = None
    kms_weekly: Optional[int] = None
    kms_monthly: Optional[int] = None
    deposit: Optional[float] = None
    salik_surcharge: Optional[float] = None
    vat_rate: Optional[float] = None
    delivery_fee: float = 0.0

class VehiclePricing(VehiclePricingBase, ORMModel):
    id: int
    vehicle_id: int

class VehicleSpecificationBase(BaseModel):
    engine: Optional[str] = None
    power: Optional[str] = None
    torque: Optional[str] = None
    seats: Optional[int] = None
    doors: Optional[int] = None
    luggage: Optional[int] = None
    transmission: Optional[str] = None
    fuel: Optional[str] = None
    year: Optional[int] = None

class VehicleSpecification(VehicleSpecificationBase, ORMModel):
    id: int
    vehicle_id: int

class VehicleFeatureBase(BaseModel):
    feature_name: str

class VehicleFeature(VehicleFeatureBase, ORMModel):
    id: int
    vehicle_id: int

class VehicleColorBase(BaseModel):
    name: str
    hex_code: str

class VehicleColor(VehicleColorBase, ORMModel):
    id: int
    vehicle_id: int

class VehicleBase(BaseModel):
    slug: str
    brand_id: int
    category_id: int
    model: str
    name: str
    year: int
    tagline: Optional[str] = None
    description: Optional[str] = None
    featured: bool = False
    is_popular: bool = False
    is_new_arrival: bool = False
    available: bool = True
    quantity: int = 1
    badge: Optional[str] = None
    rating: float = 0.0
    review_count: int = 0
    min_driver_age: int = 21
    delivery_available: bool = True
    licence_required: Optional[List[str]] = None
    related_vehicles: Optional[List[str]] = None
    keywords: Optional[List[str]] = None
    rental_includes: Optional[List[str]] = None
    seo_title: Optional[str] = None
    seo_description: Optional[str] = None

class VehicleCreate(VehicleBase):
    pricing: Optional[VehiclePricingBase] = None
    specifications: Optional[VehicleSpecificationBase] = None

class Vehicle(VehicleBase, ORMModel):
    id: int
    brand_rel: Optional[Brand] = None
    category_rel: Optional[Category] = None
    images: List[VehicleImage] = []
    pricing: Optional[VehiclePricing] = None
    specifications: Optional[VehicleSpecification] = None
    features: List[VehicleFeature] = []
    colors: List[VehicleColor] = []

class FAQBase(BaseModel):
    category: Optional[str] = None
    question: str
    answer: str
    vehicle_id: Optional[int] = None

class FAQ(FAQBase, ORMModel):
    id: int

class TestimonialBase(BaseModel):
    name: str
    role: Optional[str] = None
    content: str
    rating: float
    image_url: Optional[str] = None

class Testimonial(TestimonialBase, ORMModel):
    id: int

class OfferBase(BaseModel):
    title: str
    description: Optional[str] = None
    discount_percentage: Optional[float] = None
    valid_until: Optional[date] = None

class Offer(OfferBase, ORMModel):
    id: int

class SiteSettingBase(BaseModel):
    key: str
    value: Optional[str] = None

class SiteSetting(SiteSettingBase, ORMModel):
    id: int

class MembershipFeatureBase(BaseModel):
    text: str
    included: bool = True

class MembershipFeature(MembershipFeatureBase, ORMModel):
    id: int
    tier_id: int

class MembershipTierBase(BaseModel):
    name: str
    tagline: Optional[str] = None
    price_per_month: float
    price_per_year: Optional[float] = None
    highlighted: bool = False
    badge: Optional[str] = None
    cta_label: Optional[str] = None

class MembershipTier(MembershipTierBase, ORMModel):
    id: int
    features: List[MembershipFeature] = []

class RoleBase(BaseModel):
    name: str

class Role(RoleBase, ORMModel):
    id: int

class UserBase(BaseModel):
    email: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    country: Optional[str] = None

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    country: Optional[str] = None
    profile_image: Optional[str] = None

class UserPasswordUpdate(BaseModel):
    old_password: str
    new_password: str

class UserResponse(UserBase, ORMModel):
    id: int
    role_id: Optional[int] = None
    profile_image: Optional[str] = None
    status: str
    is_verified: bool
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None

class UserMeResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    permissions: List[str]
    avatar: Optional[str] = None
    created_at: datetime
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone: Optional[str] = None
    country: Optional[str] = None
    status: Optional[str] = None
    is_verified: Optional[bool] = None
    role_id: Optional[int] = None

    model_config = ConfigDict(from_attributes=True)

class UserStatusUpdate(BaseModel):
    status: str # active, disabled

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str

class TokenPayload(BaseModel):
    sub: Optional[str] = None # user_id
    role: Optional[str] = None # role name
    exp: Optional[int] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class PasswordResetRequest(BaseModel):
    email: str

class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str

class ActivityLogBase(BaseModel):
    action: str
    details: Optional[str] = None
    ip_address: Optional[str] = None

class ActivityLog(ActivityLogBase, ORMModel):
    id: int
    user_id: Optional[int] = None
    created_at: datetime

class BookingCreate(BaseModel):
    vehicle_id: int
    start_date: datetime
    end_date: datetime
    total_price: float
    duration_type: Optional[str] = 'daily'  # daily | weekly | monthly
    notes: Optional[str] = None

class BookingResponse(ORMModel):
    id: int
    vehicle_id: int
    user_id: Optional[int] = None
    start_date: datetime
    end_date: datetime
    total_price: float
    status: str
    created_at: datetime

class GoogleLoginRequest(BaseModel):
    id_token: str
