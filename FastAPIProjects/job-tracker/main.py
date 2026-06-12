from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from database import engine, Base
from routes import company_router, application_router, contact_router, interview_router
import db_models
from fastapi.middleware.cors import CORSMiddleware




Base.metadata.create_all(bind=engine)

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("Job Application Tracker started.")
    yield

app = FastAPI(
    title="Job Application Tracker API",
    version="1.0.0",
    description="Track companies, applications, contacts and interviews — built with FastAPI and SQL Server",
    lifespan=lifespan
)

app.include_router(company_router,     prefix="/api/v1")
app.include_router(application_router, prefix="/api/v1")
app.include_router(contact_router,     prefix="/api/v1")
app.include_router(interview_router,   prefix="/api/v1")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],      # In production, replace * with your frontend URL
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred. Please try again later."}
    )

@app.get("/")
def root():
    return {
        "message": "Job Application Tracker API",
        "docs": "/docs",
        "version": "1.0.0"
    }