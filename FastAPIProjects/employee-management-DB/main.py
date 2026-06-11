# main.py
 
from fastapi import FastAPI
from database import engine
from db_models import Base
from routes import router
 
# Create all tables if they don't exist
# Equivalent to running the CREATE TABLE scripts
Base.metadata.create_all(bind=engine)
 
app = FastAPI(title='Employee DB API', version='3.0.0')
app.include_router(router, prefix='/api/v1')
 
@app.get('/')
def root():
    return {"api": "Employee DB API", "database": "SQL Server", "status": "connected"}
