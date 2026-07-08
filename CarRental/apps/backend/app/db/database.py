from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

# For SQLite, connect_args={"check_same_thread": False}
connect_args = {"check_same_thread": False} if settings.DATABASE_URI.startswith("sqlite") else {}

engine = create_engine(
    settings.DATABASE_URI,
    connect_args=connect_args
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
