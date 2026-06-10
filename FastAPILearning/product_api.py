from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, field_validator
from typing import List, Optional

app = FastAPI(
    title = "Product API",
    description = "A basic Product Management API",
    version = "1.0.0"
)

class ProductCreate(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    in_stock: bool = True

    @field_validator("price")
    @classmethod
    def price_must_be_positive(cls, v):
        if v <= 0:
                raise ValueError("Price must be positive")
        return v

    @field_validator("name")
    @classmethod
    def name_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError("Name must not be empty")
        return v.strip()
    
class Product(ProductCreate):
    id: int

products_db: List[Product] = []
next_product_id = 1  # Auto-incrementing ID counter

@app.post("/products/", response_model=Product, status_code=201)
def create_product(product: ProductCreate):
    global next_product_id

    new_product = Product(
        id=next_product_id,
        **product.model_dump()
    )

    products_db.append(new_product)
    next_product_id += 1

    return new_product

@app.get("/products/", response_model=List[Product])
def list_products():
    return products_db

@app.get("/products/{product_id}", response_model=Product)
def get_product(product_id: int):
    for product in products_db:
        if product.id == product_id:
            return product
    raise HTTPException(status_code=404, detail="Product not found")

@app.put("/products/{product_id}", response_model=Product)
def update_product(product_id: int, product_update: ProductCreate):
    for index, product in enumerate(products_db):
        if product.id == product_id:
            updated_product = Product(
                id=product_id,
                **product_update.model_dump()
            )
            products_db[index] = updated_product
            return updated_product
    raise HTTPException(status_code=404, detail="Product not found")

@app.delete("/products/{product_id}", status_code=204)
def delete_product(product_id: int):
    for index, product in enumerate(products_db):
        if product.id == product_id:
            del products_db[index]
            return
    raise HTTPException(status_code=404, detail="Product not found")


