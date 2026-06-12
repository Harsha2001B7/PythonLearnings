from fastapi import APIRouter, HTTPException, Depends, Query
from sqlalchemy.orm import Session
from typing import Optional
from database import get_db
from db_models import ApplicationStatus
from models import (
    CompanyCreate, CompanyUpdate, CompanyResponse, CompanyListResponse,
    ApplicationCreate, ApplicationUpdate, ApplicationResponse, ApplicationListResponse,
    ContactCreate, ContactUpdate, ContactResponse, ContactListResponse,
    InterviewCreate, InterviewUpdate, InterviewResponse, InterviewListResponse
)
from service import company_service, application_service, contact_service, interview_service
from exceptions import (
    CompanyNotFoundException, CompanyAlreadyExistsException,
    ApplicationNotFoundException, InvalidStatusTransitionException,
    ContactNotFoundException, InterviewNotFoundException,
    ApplicationNotInInterviewStageException
)

# ─── COMPANY ROUTER ───────────────────────────────────────────
company_router = APIRouter(prefix="/companies", tags=["Companies"])

@company_router.post("/", response_model=CompanyResponse, status_code=201)
def create_company(data: CompanyCreate, db: Session = Depends(get_db)):
    try:
        return company_service.create_company(db, data)
    except CompanyAlreadyExistsException as e:
        raise HTTPException(status_code=409, detail=str(e))

@company_router.get("/", response_model=CompanyListResponse)
def get_all_companies(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    return company_service.get_all_companies(db, page, page_size)

@company_router.get("/{company_id}", response_model=CompanyResponse)
def get_company(company_id: int, db: Session = Depends(get_db)):
    try:
        return company_service.get_company(db, company_id)
    except CompanyNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@company_router.patch("/{company_id}", response_model=CompanyResponse)
def update_company(company_id: int, data: CompanyUpdate, db: Session = Depends(get_db)):
    try:
        return company_service.update_company(db, company_id, data)
    except CompanyNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    except CompanyAlreadyExistsException as e:
        raise HTTPException(status_code=409, detail=str(e))

@company_router.delete("/{company_id}", status_code=204)
def delete_company(company_id: int, db: Session = Depends(get_db)):
    try:
        company_service.delete_company(db, company_id)
    except CompanyNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))


# ─── APPLICATION ROUTER ───────────────────────────────────────
application_router = APIRouter(prefix="/applications", tags=["Applications"])

@application_router.post("/", response_model=ApplicationResponse, status_code=201)
def create_application(data: ApplicationCreate, db: Session = Depends(get_db)):
    try:
        return application_service.create_application(db, data)
    except CompanyNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@application_router.get("/", response_model=ApplicationListResponse)
def get_all_applications(
    status: Optional[ApplicationStatus] = Query(None),
    company_id: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    return application_service.get_all_applications(db, status, company_id, page, page_size)

@application_router.get("/{application_id}", response_model=ApplicationResponse)
def get_application(application_id: int, db: Session = Depends(get_db)):
    try:
        return application_service.get_application(db, application_id)
    except ApplicationNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@application_router.patch("/{application_id}", response_model=ApplicationResponse)
def update_application(application_id: int, data: ApplicationUpdate, db: Session = Depends(get_db)):
    try:
        return application_service.update_application(db, application_id, data)
    except ApplicationNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    except InvalidStatusTransitionException as e:
        raise HTTPException(status_code=422, detail=str(e))

@application_router.delete("/{application_id}", status_code=204)
def delete_application(application_id: int, db: Session = Depends(get_db)):
    try:
        application_service.delete_application(db, application_id)
    except ApplicationNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))


# ─── CONTACT ROUTER ───────────────────────────────────────────
contact_router = APIRouter(prefix="/contacts", tags=["Contacts"])

@contact_router.post("/", response_model=ContactResponse, status_code=201)
def create_contact(data: ContactCreate, db: Session = Depends(get_db)):
    try:
        return contact_service.create_contact(db, data)
    except CompanyNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@contact_router.get("/", response_model=ContactListResponse)
def get_all_contacts(
    company_id: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    return contact_service.get_all_contacts(db, company_id, page, page_size)

@contact_router.get("/{contact_id}", response_model=ContactResponse)
def get_contact(contact_id: int, db: Session = Depends(get_db)):
    try:
        return contact_service.get_contact(db, contact_id)
    except ContactNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@contact_router.patch("/{contact_id}", response_model=ContactResponse)
def update_contact(contact_id: int, data: ContactUpdate, db: Session = Depends(get_db)):
    try:
        return contact_service.update_contact(db, contact_id, data)
    except ContactNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@contact_router.delete("/{contact_id}", status_code=204)
def delete_contact(contact_id: int, db: Session = Depends(get_db)):
    try:
        contact_service.delete_contact(db, contact_id)
    except ContactNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))


# ─── INTERVIEW ROUTER ─────────────────────────────────────────
interview_router = APIRouter(prefix="/interviews", tags=["Interviews"])

@interview_router.post("/", response_model=InterviewResponse, status_code=201)
def create_interview(data: InterviewCreate, db: Session = Depends(get_db)):
    try:
        return interview_service.create_interview(db, data)
    except ApplicationNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))
    except ApplicationNotInInterviewStageException as e:
        raise HTTPException(status_code=422, detail=str(e))

@interview_router.get("/", response_model=InterviewListResponse)
def get_all_interviews(
    application_id: Optional[int] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    db: Session = Depends(get_db)
):
    return interview_service.get_all_interviews(db, application_id, page, page_size)

@interview_router.get("/{interview_id}", response_model=InterviewResponse)
def get_interview(interview_id: int, db: Session = Depends(get_db)):
    try:
        return interview_service.get_interview(db, interview_id)
    except InterviewNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@interview_router.patch("/{interview_id}", response_model=InterviewResponse)
def update_interview(interview_id: int, data: InterviewUpdate, db: Session = Depends(get_db)):
    try:
        return interview_service.update_interview(db, interview_id, data)
    except InterviewNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))

@interview_router.delete("/{interview_id}", status_code=204)
def delete_interview(interview_id: int, db: Session = Depends(get_db)):
    try:
        interview_service.delete_interview(db, interview_id)
    except InterviewNotFoundException as e:
        raise HTTPException(status_code=404, detail=str(e))