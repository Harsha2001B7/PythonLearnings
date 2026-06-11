from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from routes import router
from database import engine, Base
from seed import run_seeds
from contextlib import asynccontextmanager

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Student Management API",
    version="1.0.0",
    description="A REST API for managing students built with FastAPI and SQL Server"
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    run_seeds()
    yield

app.include_router(router, prefix="/api/v1")

@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred. Please try again later."}
    )

@app.get("/")
def root():
    return {
        "message": "Welcome to Student Management API",
        "docs": "/docs",
        "version": "1.0.0"
    }