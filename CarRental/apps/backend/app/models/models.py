from sqlalchemy import Column, Integer, String, Float, Boolean, ForeignKey, Text, JSON, DateTime, Date
from sqlalchemy.orm import relationship
from datetime import datetime
from app.db.base import Base

class Role(Base):
    __tablename__ = "roles"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), unique=True, nullable=False) # Admin, User
    
    users = relationship("User", back_populates="role_rel")

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=True)
    last_name = Column(String(100), nullable=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    phone = Column(String(50), nullable=True)
    password_hash = Column(String(255), nullable=False)
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=True)
    profile_image = Column(String(255), nullable=True)
    country = Column(String(100), nullable=True)
    status = Column(String(50), default="active") # active, disabled
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = Column(DateTime, nullable=True)

    # Relationships
    role_rel = relationship("Role", back_populates="users")
    refresh_tokens = relationship("RefreshToken", back_populates="user", cascade="all, delete-orphan")
    sessions = relationship("UserSession", back_populates="user", cascade="all, delete-orphan")
    activity_logs = relationship("ActivityLog", back_populates="user", cascade="all, delete-orphan")

class RefreshToken(Base):
    __tablename__ = "refresh_tokens"
    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(512), unique=True, index=True, nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    revoked_at = Column(DateTime, nullable=True)

    user = relationship("User", back_populates="refresh_tokens")

class UserSession(Base):
    __tablename__ = "user_sessions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    ip_address = Column(String(50), nullable=True)
    user_agent = Column(String(255), nullable=True)
    last_activity = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="sessions")

class PasswordResetToken(Base):
    __tablename__ = "password_reset_tokens"
    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(255), unique=True, index=True, nullable=False)
    email = Column(String(255), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    used_at = Column(DateTime, nullable=True)

class EmailVerificationToken(Base):
    __tablename__ = "email_verification_tokens"
    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(255), unique=True, index=True, nullable=False)
    email = Column(String(255), nullable=False)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    used_at = Column(DateTime, nullable=True)

class ActivityLog(Base):
    __tablename__ = "activity_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    action = Column(String(255), nullable=False) # e.g. "Create Vehicle", "Update Booking"
    details = Column(Text, nullable=True)
    ip_address = Column(String(50), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="activity_logs")


class Brand(Base):
    __tablename__ = "brands"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    slug = Column(String, unique=True, index=True, nullable=False)
    logo_url = Column(String)
    
    vehicles = relationship("Vehicle", back_populates="brand_rel")

class Category(Base):
    __tablename__ = "categories"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True, nullable=False)
    slug = Column(String, unique=True, index=True, nullable=False)
    
    vehicles = relationship("Vehicle", back_populates="category_rel")

class Vehicle(Base):
    __tablename__ = "vehicles"
    id = Column(Integer, primary_key=True, index=True)
    slug = Column(String, unique=True, index=True, nullable=False)
    brand_id = Column(Integer, ForeignKey("brands.id"), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False)
    model = Column(String, nullable=False)
    name = Column(String, nullable=False)
    year = Column(Integer, nullable=False)
    tagline = Column(String)
    description = Column(Text)
    
    featured = Column(Boolean, default=False)
    is_popular = Column(Boolean, default=False)
    is_new_arrival = Column(Boolean, default=False)
    available = Column(Boolean, default=True)
    badge = Column(String)
    
    rating = Column(Float, default=0.0)
    review_count = Column(Integer, default=0)
    min_driver_age = Column(Integer, default=21)
    delivery_available = Column(Boolean, default=True)
    
    # Relationships
    brand_rel = relationship("Brand", back_populates="vehicles")
    category_rel = relationship("Category", back_populates="vehicles")
    
    images = relationship("VehicleImage", back_populates="vehicle", cascade="all, delete-orphan")
    pricing = relationship("VehiclePricing", back_populates="vehicle", uselist=False, cascade="all, delete-orphan")
    specifications = relationship("VehicleSpecification", back_populates="vehicle", uselist=False, cascade="all, delete-orphan")
    features = relationship("VehicleFeature", back_populates="vehicle", cascade="all, delete-orphan")
    colors = relationship("VehicleColor", back_populates="vehicle", cascade="all, delete-orphan")
    
    # Store lists like licence_required, related_vehicles, keywords as JSON for simplicity, or related tables. JSON is fine for array of strings.
    licence_required = Column(JSON)
    related_vehicles = Column(JSON)
    keywords = Column(JSON)
    rental_includes = Column(JSON)
    seo_title = Column(String)
    seo_description = Column(String)

class VehicleImage(Base):
    __tablename__ = "vehicle_images"
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=False)
    image_url = Column(String, nullable=False)
    image_type = Column(String) # thumbnail, exterior, interior
    
    vehicle = relationship("Vehicle", back_populates="images")

class VehiclePricing(Base):
    __tablename__ = "vehicle_pricing"
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), unique=True, nullable=False)
    daily = Column(Float, nullable=False)
    weekly = Column(Float, nullable=False)
    monthly = Column(Float, nullable=False)
    excess_per_km = Column(Float)
    kms_daily = Column(Integer)
    kms_weekly = Column(Integer)
    kms_monthly = Column(Integer)
    deposit = Column(Float)
    salik_surcharge = Column(Float)
    vat_rate = Column(Float)
    delivery_fee = Column(Float, default=0)
    
    vehicle = relationship("Vehicle", back_populates="pricing")

class VehicleSpecification(Base):
    __tablename__ = "vehicle_specifications"
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), unique=True, nullable=False)
    engine = Column(String)
    power = Column(String)
    torque = Column(String)
    seats = Column(Integer)
    doors = Column(Integer)
    luggage = Column(Integer)
    transmission = Column(String)
    fuel = Column(String)
    year = Column(Integer)
    
    vehicle = relationship("Vehicle", back_populates="specifications")

class VehicleFeature(Base):
    __tablename__ = "vehicle_features"
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=False)
    feature_name = Column(String, nullable=False)
    
    vehicle = relationship("Vehicle", back_populates="features")

class VehicleColor(Base):
    __tablename__ = "vehicle_colors"
    id = Column(Integer, primary_key=True, index=True)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=False)
    name = Column(String, nullable=False)
    hex_code = Column(String, nullable=False)
    
    vehicle = relationship("Vehicle", back_populates="colors")

class FAQ(Base):
    __tablename__ = "faqs"
    id = Column(Integer, primary_key=True, index=True)
    category = Column(String, nullable=True)
    question = Column(String, nullable=False)
    answer = Column(Text, nullable=False)
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=True) # If null, it's a general FAQ
    
    vehicle = relationship("Vehicle")

class Testimonial(Base):
    __tablename__ = "testimonials"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    role = Column(String)
    content = Column(Text, nullable=False)
    rating = Column(Float, nullable=False)
    image_url = Column(String)

class Offer(Base):
    __tablename__ = "offers"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(Text)
    discount_percentage = Column(Float)
    valid_until = Column(Date)

class HeroBanner(Base):
    __tablename__ = "hero_banners"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    subtitle = Column(String)
    image_url = Column(String, nullable=False)
    cta_text = Column(String)
    cta_link = Column(String)
    is_active = Column(Boolean, default=True)

class SiteSetting(Base):
    __tablename__ = "site_settings"
    id = Column(Integer, primary_key=True, index=True)
    key = Column(String, unique=True, index=True, nullable=False)
    value = Column(String)

class Booking(Base):
    __tablename__ = "bookings"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    vehicle_id = Column(Integer, ForeignKey("vehicles.id"), nullable=False)
    start_date = Column(DateTime, nullable=False)
    end_date = Column(DateTime, nullable=False)
    total_price = Column(Float, nullable=False)
    status = Column(String, default="pending") # pending, confirmed, cancelled, completed
    created_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User")
    vehicle = relationship("Vehicle")

class MembershipTier(Base):
    __tablename__ = "membership_tiers"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    tagline = Column(String(200))
    price_per_month = Column(Float, nullable=False)
    price_per_year = Column(Float)
    highlighted = Column(Boolean, default=False)
    badge = Column(String(100))
    cta_label = Column(String(100))

    features = relationship("MembershipFeature", back_populates="tier", cascade="all, delete-orphan")

class MembershipFeature(Base):
    __tablename__ = "membership_features"

    id = Column(Integer, primary_key=True, index=True)
    tier_id = Column(Integer, ForeignKey("membership_tiers.id"), nullable=False)
    text = Column(String(255), nullable=False)
    included = Column(Boolean, default=True)

    tier = relationship("MembershipTier", back_populates="features")
