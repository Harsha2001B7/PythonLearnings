from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from routes import router

app = FastAPI(title="Employee Management API", version="1.0.0")

app.include_router(router, prefix="/api/v1")

@app.exception_handler(Exception)
async def generic_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "An unexpected error occurred. Please try again later."}
    )

@app.get("/")
def root():
    return {"message": "Welcome to the Employee Management API. Visit /docs for API documentation."}
