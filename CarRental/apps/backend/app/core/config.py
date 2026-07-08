import os
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    PROJECT_NAME: str = "FalconViewCarRentals"
    API_V1_STR: str = "/api/v1"
    BACKEND_CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:5173", "http://127.0.0.1:5173"]
    
    # Path to the sqlite database
    # Construct absolute path to apps/data/sqlite/falconview.db
    DATABASE_URI: str = f"sqlite:///{os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))), 'data', 'sqlite', 'falconview.db')}"
    
    # Static files directory
    UPLOADS_DIR: str = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "static", "uploads")

    class Config:
        case_sensitive = True

settings = Settings()
