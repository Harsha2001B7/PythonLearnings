# config.py

from pydantic import model_validator
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    # Gemini
    gemini_api_key: str

    # Database — Windows Authentication
    db_server: str = 'localhost'
    db_name:   str = 'JobTrackerDB'
    db_driver: str = 'ODBC Driver 17 for SQL Server'

    # Application
    max_sql_rows:       int  = 100
    enable_sql_logging: bool = True
    allowed_tables:     str  = 'companies,applications'

    # Computed
    allowed_tables_list: List[str] = []

    @model_validator(mode='after')
    def compute_derived_fields(self) -> 'Settings':
        self.allowed_tables_list = [t.strip() for t in self.allowed_tables.split(',')]
        return self

    model_config = {'env_file': '.env', 'extra': 'ignore'}

settings = Settings()