# database.py

from sqlalchemy import create_engine
from sqlalchemy.engine import URL
from sqlalchemy.orm import sessionmaker
from config import settings

odbc_str = (
    f"DRIVER={{{settings.db_driver}}};"
    f"SERVER={settings.db_server};"
    f"DATABASE={settings.db_name};"
    f"Trusted_Connection=yes;"
    f"TrustServerCertificate=yes;"
)

connection_url = URL.create(
    "mssql+pyodbc",
    query={"odbc_connect": odbc_str}
)

engine = create_engine(
    connection_url,
    echo=settings.enable_sql_logging,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()