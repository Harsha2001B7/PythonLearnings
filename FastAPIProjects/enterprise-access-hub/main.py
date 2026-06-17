from fastapi import FastAPI
from routers.auth_router import router as auth_router
from routers.user_router import router as user_router
from routers.workspace_router import router as workspace_router
from database import engine
from models.role import Role
from models.user import User
from models.workspace import Workspace
from models.base import Base
from middleware.request_timer import (
    request_timer
)
from exceptions.app_exceptions import (
    AppException
)

from exceptions.handlers import (
    app_exception_handler
)

from starlette.middleware.base import BaseHTTPMiddleware

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Enterprise Access Hub API")

app.add_middleware(
    BaseHTTPMiddleware,

    dispatch=request_timer
)

app.add_exception_handler(

    AppException,

    app_exception_handler
)

app.include_router(
    auth_router
)

app.include_router(
    user_router
)

app.include_router(
    workspace_router
)

app.middleware(
    "http"
)(
    request_timer
)

@app.get("/")
def Home():
    return {"message" : "API is running"}