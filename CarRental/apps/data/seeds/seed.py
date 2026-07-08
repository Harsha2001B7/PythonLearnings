import os
import sys
import re
import shutil

# Setup path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "backend"))

from app.core.config import settings
from app.db.session import SessionLocal
from app.models.models import Brand, Category, Vehicle, VehiclePricing, VehicleSpecification, VehicleFeature, VehicleImage, VehicleColor

def seed_data():
    db = SessionLocal()
    
    # Paths
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    fleet_file = os.path.join(base_dir, "web", "src", "data", "fleet.ts")
    assets_dir = os.path.join(base_dir, "web", "assets", "cars")
    uploads_dir = os.path.join(settings.UPLOADS_DIR, "vehicles")
    
    os.makedirs(uploads_dir, exist_ok=True)
    
    with open(fleet_file, "r", encoding="utf-8") as f:
        content = f.read()
    
    # 1. Parse Image Imports mapping
    # e.g. import imgAttrage from '../../assets/cars/Mirage-Attrage.jpg';
    img_imports = {}
    for match in re.finditer(r"import\s+([a-zA-Z0-9_]+)\s+from\s+['\"](.*?)['\"];", content):
        var_name = match.group(1)
        path_str = match.group(2)
        filename = os.path.basename(path_str)
        img_imports[var_name] = filename
        
        # Move image to backend
        src_path = os.path.join(assets_dir, filename)
        dst_path = os.path.join(uploads_dir, filename)
        if os.path.exists(src_path):
            shutil.copy2(src_path, dst_path)
            
    # 2. Extract vehicle objects (roughly)
    # Using a regex to find the blocks between { and }, or just extract fields per block
    # Since they are well formatted, let's split by "// ── "
    blocks = content.split("// ── ")[1:]
    for block in blocks:
        # Extract fields
        def get_str(key):
            m = re.search(fr"{key}:\s*['\"](.*?)['\"]", block)
            return m.group(1) if m else None
            
        def get_int(key):
            m = re.search(fr"{key}:\s*(\d+)", block)
            return int(m.group(1)) if m else 0
            
        def get_float(key):
            m = re.search(fr"{key}:\s*([\d\.]+)", block)
            return float(m.group(1)) if m else 0.0
            
        def get_bool(key):
            m = re.search(fr"{key}:\s*(true|false)", block)
            return m.group(1) == "true" if m else False
            
        slug = get_str("slug")
        if not slug: continue
        
        brand_name = get_str("brand")
        category_name = get_str("category")
        
        # Ensure brand exists
        brand = db.query(Brand).filter(Brand.name == brand_name).first()
        if not brand:
            brand = Brand(name=brand_name, slug=brand_name.lower().replace(" ", "-"))
            db.add(brand)
            db.commit()
            
        # Ensure category exists
        category = db.query(Category).filter(Category.slug == category_name).first()
        if not category:
            category = Category(name=category_name.capitalize(), slug=category_name)
            db.add(category)
            db.commit()
            
        vehicle = db.query(Vehicle).filter(Vehicle.slug == slug).first()
        if not vehicle:
            vehicle = Vehicle(
                slug=slug,
                brand_id=brand.id,
                category_id=category.id,
                model=get_str("model"),
                name=get_str("name"),
                year=get_int("year"),
                tagline=get_str("tagline"),
                description=get_str("description"),
                featured=get_bool("featured"),
                is_popular=get_bool("is_popular"),
                is_new_arrival=get_bool("is_new_arrival"),
                available=get_bool("available"),
                badge=get_str("badge"),
                rating=get_float("rating"),
                review_count=get_int("reviewCount"),
                min_driver_age=get_int("minDriverAge"),
                delivery_available=get_bool("deliveryAvailable"),
                seo_title=get_str("seoTitle"),
                seo_description=get_str("seoDescription")
            )
            db.add(vehicle)
            db.commit()
            
            # Pricing
            daily = get_float("daily")
            weekly = get_float("weekly")
            monthly = get_float("monthly")
            if daily:
                pricing = VehiclePricing(
                    vehicle_id=vehicle.id,
                    daily=daily,
                    weekly=weekly,
                    monthly=monthly,
                    excess_per_km=get_float("excessPerKm"),
                    kms_daily=300,
                    kms_weekly=200,
                    kms_monthly=4000,
                    deposit=get_float("deposit"),
                    salik_surcharge=1.0,
                    vat_rate=5.0,
                    delivery_fee=0.0
                )
                db.add(pricing)
            
            # Specs
            specs_match = re.search(r"specs:\s*\{(.*?)\}", block, re.DOTALL)
            if specs_match:
                specs_str = specs_match.group(1)
                engine_m = re.search(r"engine:\s*['\"](.*?)['\"]", specs_str)
                power_m = re.search(r"power:\s*['\"](.*?)['\"]", specs_str)
                torque_m = re.search(r"torque:\s*['\"](.*?)['\"]", specs_str)
                seats_m = re.search(r"seats:\s*(\d+)", specs_str)
                
                specs = VehicleSpecification(
                    vehicle_id=vehicle.id,
                    engine=engine_m.group(1) if engine_m else None,
                    power=power_m.group(1) if power_m else None,
                    torque=torque_m.group(1) if torque_m else None,
                    seats=int(seats_m.group(1)) if seats_m else None
                )
                db.add(specs)
                
            # Features
            feat_match = re.search(r"features:\s*\[(.*?)\]", block, re.DOTALL)
            if feat_match:
                feats = re.findall(r"['\"](.*?)['\"]", feat_match.group(1))
                for feat in feats:
                    db.add(VehicleFeature(vehicle_id=vehicle.id, feature_name=feat))
                    
            # Colors
            color_match = re.search(r"colors:\s*\[(.*?)\]", block, re.DOTALL)
            if color_match:
                colors = re.findall(r"\{\s*name:\s*['\"](.*?)['\"],\s*hex:\s*['\"](.*?)['\"]\s*\}", color_match.group(1))
                for c_name, c_hex in colors:
                    db.add(VehicleColor(vehicle_id=vehicle.id, name=c_name, hex_code=c_hex))
                    
            # Images
            img_match = re.search(r"images:\s*\{(.*?)\}", block, re.DOTALL)
            if img_match:
                img_str = img_match.group(1)
                thumb_m = re.search(r"thumbnail:\s*([a-zA-Z0-9_]+)", img_str)
                if thumb_m and thumb_m.group(1) in img_imports:
                    db.add(VehicleImage(vehicle_id=vehicle.id, image_url=f"/static/vehicles/{img_imports[thumb_m.group(1)]}", image_type="thumbnail"))
            
            db.commit()

    print("Seed complete!")

if __name__ == "__main__":
    seed_data()
