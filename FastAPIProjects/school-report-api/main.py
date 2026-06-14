from fastapi import FastAPI

from routers.auth_router import router as auth_router
from routers.report_router import router as report_router

app = FastAPI(
    title="School Reporting API"
)

app.include_router(auth_router)
app.include_router(report_router)


@app.get("/")
def home():
    return {
        "message": "School Reporting API"
    }