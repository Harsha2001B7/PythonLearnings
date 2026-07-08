from typing import Any, Dict, Generic, List, Optional, Type, TypeVar, Union
from pydantic import BaseModel
from sqlalchemy.orm import Session
from app.db.base import Base

ModelType = TypeVar("ModelType", bound=Base)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType]):
    def __init__(self, model: Type[ModelType]):
        self.model = model

    def get(self, db: Session, id: Any) -> Optional[ModelType]:
        return db.query(self.model).filter(self.model.id == id).first()

    def get_multi(self, db: Session, *, skip: int = 0, limit: int = 100) -> List[ModelType]:
        return db.query(self.model).offset(skip).limit(limit).all()

    def create(self, db: Session, *, obj_in: CreateSchemaType) -> ModelType:
        obj_in_data = obj_in.model_dump()
        db_obj = self.model(**obj_in_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update(
        self, db: Session, *, db_obj: ModelType, obj_in: Union[UpdateSchemaType, Dict[str, Any]]
    ) -> ModelType:
        obj_data = db_obj.__dict__
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)
        for field in obj_data:
            if field in update_data:
                setattr(db_obj, field, update_data[field])
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def remove(self, db: Session, *, id: int) -> ModelType:
        obj = db.query(self.model).get(id)
        db.delete(obj)
        db.commit()
        return obj

from app.models.models import Brand, Category, Vehicle, FAQ, Testimonial, Offer, SiteSetting
from app.schemas.schemas import (
    BrandCreate, CategoryCreate, VehicleCreate, FAQBase, TestimonialBase, OfferBase, SiteSettingBase
)

class CRUDBrand(CRUDBase[Brand, BrandCreate, BrandCreate]):
    pass

class CRUDCategory(CRUDBase[Category, CategoryCreate, CategoryCreate]):
    pass

from sqlalchemy.orm import joinedload, selectinload

class CRUDVehicle(CRUDBase[Vehicle, VehicleCreate, VehicleCreate]):
    def get(self, db: Session, id: Any) -> Optional[Vehicle]:
        return (
            db.query(self.model)
            .filter(self.model.id == id)
            .options(
                joinedload(Vehicle.brand_rel),
                joinedload(Vehicle.category_rel),
                selectinload(Vehicle.images),
                joinedload(Vehicle.pricing),
                joinedload(Vehicle.specifications),
                selectinload(Vehicle.features),
                selectinload(Vehicle.colors)
            )
            .first()
        )

    def get_multi(self, db: Session, *, skip: int = 0, limit: int = 100) -> List[Vehicle]:
        return (
            db.query(self.model)
            .options(
                joinedload(Vehicle.brand_rel),
                joinedload(Vehicle.category_rel),
                selectinload(Vehicle.images),
                joinedload(Vehicle.pricing),
                joinedload(Vehicle.specifications),
                selectinload(Vehicle.features),
                selectinload(Vehicle.colors)
            )
            .offset(skip)
            .limit(limit)
            .all()
        )

    def get_by_slug(self, db: Session, slug: str) -> Optional[Vehicle]:
        return (
            db.query(self.model)
            .filter(self.model.slug == slug)
            .options(
                joinedload(Vehicle.brand_rel),
                joinedload(Vehicle.category_rel),
                selectinload(Vehicle.images),
                joinedload(Vehicle.pricing),
                joinedload(Vehicle.specifications),
                selectinload(Vehicle.features),
                selectinload(Vehicle.colors)
            )
            .first()
        )

    def create(self, db: Session, *, obj_in: VehicleCreate) -> Vehicle:
        obj_in_data = obj_in.model_dump()
        pricing_data = obj_in_data.pop("pricing", None)
        specs_data = obj_in_data.pop("specifications", None)
        
        db_obj = self.model(**obj_in_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        
        if pricing_data:
            from app.models.models import VehiclePricing
            db_pricing = VehiclePricing(vehicle_id=db_obj.id, **pricing_data)
            db.add(db_pricing)
            
        if specs_data:
            from app.models.models import VehicleSpecification
            db_specs = VehicleSpecification(vehicle_id=db_obj.id, **specs_data)
            db.add(db_specs)
            
        db.commit()
        return self.get(db, id=db_obj.id)

    def update(
        self, db: Session, *, db_obj: Vehicle, obj_in: Union[VehicleCreate, Dict[str, Any]]
    ) -> Vehicle:
        if isinstance(obj_in, dict):
            update_data = obj_in.copy()
        else:
            update_data = obj_in.model_dump(exclude_unset=True)
            
        pricing_data = update_data.pop("pricing", None)
        specs_data = update_data.pop("specifications", None)
        
        for field in update_data:
            if hasattr(db_obj, field):
                setattr(db_obj, field, update_data[field])
        db.add(db_obj)
        
        if pricing_data:
            from app.models.models import VehiclePricing
            if db_obj.pricing:
                for k, v in pricing_data.items():
                    setattr(db_obj.pricing, k, v)
                db.add(db_obj.pricing)
            else:
                db_pricing = VehiclePricing(vehicle_id=db_obj.id, **pricing_data)
                db.add(db_pricing)
                
        if specs_data:
            from app.models.models import VehicleSpecification
            if db_obj.specifications:
                for k, v in specs_data.items():
                    setattr(db_obj.specifications, k, v)
                db.add(db_obj.specifications)
            else:
                db_specs = VehicleSpecification(vehicle_id=db_obj.id, **specs_data)
                db.add(db_specs)
                
        db.commit()
        return self.get(db, id=db_obj.id)

class CRUDFAQ(CRUDBase[FAQ, FAQBase, FAQBase]):
    pass

class CRUDTestimonial(CRUDBase[Testimonial, TestimonialBase, TestimonialBase]):
    pass

class CRUDOffer(CRUDBase[Offer, OfferBase, OfferBase]):
    pass

class CRUDSiteSetting(CRUDBase[SiteSetting, SiteSettingBase, SiteSettingBase]):
    def get_by_key(self, db: Session, key: str) -> Optional[SiteSetting]:
        return db.query(self.model).filter(self.model.key == key).first()

brand = CRUDBrand(Brand)
category = CRUDCategory(Category)
vehicle = CRUDVehicle(Vehicle)
faq = CRUDFAQ(FAQ)
testimonial = CRUDTestimonial(Testimonial)
offer = CRUDOffer(Offer)
site_setting = CRUDSiteSetting(SiteSetting)
