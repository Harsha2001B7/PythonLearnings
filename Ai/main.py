# main.py
 
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import router
 
app = FastAPI(
    title="AI SQL Assistant",
    description="Ask questions in English, get answers from your SQL Server database",
    version="1.0.0"
)
 
# CORS middleware - allows web browsers to call this API
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],       # In production, specify your frontend URL
    allow_methods=['*'],
    allow_headers=['*'],
)
 
app.include_router(router)
 
@app.get('/')
def root():
    return {
        "name": "AI SQL Assistant",
        "docs": "/docs",
        "ask_endpoint": "/api/ask",
        "example": {"question": "How many employees are in Engineering?"}
    }
