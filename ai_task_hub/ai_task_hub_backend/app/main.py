from fastapi import FastAPI

from app.database.db import Base
from app.database.db import engine

from app.models import user
from app.models import task
from app.routers import agent_router
from app.routers import dashboard_router
from app.routers import task_router
from app.routers import user_router

app = FastAPI()

Base.metadata.create_all(bind=engine)

app.include_router(user_router.router)
app.include_router(task_router.router)
app.include_router(dashboard_router.router)
app.include_router(agent_router.router)


@app.get("/")
def health():

    return {"message": "API running"}