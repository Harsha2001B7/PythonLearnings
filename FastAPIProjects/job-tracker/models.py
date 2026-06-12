from pydantic import BaseModel, Field, ConfigDict, HttpUrl
from typing import Optional
from datetime import datetime
from db_models import ApplicationStatus, InterviewType, InterviewOutcome


# ─── COMPANY ──────────────────────────────────────────────────

class CompanyCreate(BaseModel):
    name:       str           = Field(..., min_length=1, max_length=150)
    website:    Optional[str] = Field(None, max_length=255)
    location:   Optional[str] = Field(None, max_length=150)
    industry:   Optional[str] = Field(None, max_length=100)

class CompanyUpdate(BaseModel):
    name:       Optional[str] = Field(None, min_length=1, max_length=150)
    website:    Optional[str] = Field(None, max_length=255)
    location:   Optional[str] = Field(None, max_length=150)
    industry:   Optional[str] = Field(None, max_length=100)

class CompanyResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:         int
    name:       str
    website:    Optional[str]
    location:   Optional[str]
    industry:   Optional[str]
    created_at: datetime

class CompanyListResponse(BaseModel):
    total:      int
    companies:  list[CompanyResponse]
    page:       int
    size:       int


# ─── APPLICATION ──────────────────────────────────────────────

class ApplicationCreate(BaseModel):
    company_id:     int           = Field(..., gt=0)
    role:           str           = Field(..., min_length=1, max_length=150)
    job_url:        Optional[str] = Field(None, max_length=500)
    notes:          Optional[str] = Field(None, max_length=1000)
    # status defaults to Applied — no need to send it on create

class ApplicationUpdate(BaseModel):
    role:           Optional[str]               = Field(None, min_length=1, max_length=150)
    status:         Optional[ApplicationStatus] = None
    job_url:        Optional[str]               = Field(None, max_length=500)
    notes:          Optional[str]               = Field(None, max_length=1000)

class ApplicationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:             int
    company_id:     int
    role:           str
    status:         ApplicationStatus
    job_url:        Optional[str]
    notes:          Optional[str]
    applied_date:   datetime
    created_at:     datetime

class ApplicationListResponse(BaseModel):
    total:          int
    applications:   list[ApplicationResponse]
    page:           int
    size:           int


# ─── CONTACT ──────────────────────────────────────────────────

class ContactCreate(BaseModel):
    company_id:     int           = Field(..., gt=0)
    name:           str           = Field(..., min_length=1, max_length=150)
    role:           Optional[str] = Field(None, max_length=150)
    email:          Optional[str] = Field(None, max_length=150)
    linkedin:       Optional[str] = Field(None, max_length=255)

class ContactUpdate(BaseModel):
    name:           Optional[str] = Field(None, min_length=1, max_length=150)
    role:           Optional[str] = Field(None, max_length=150)
    email:          Optional[str] = Field(None, max_length=150)
    linkedin:       Optional[str] = Field(None, max_length=255)

class ContactResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:             int
    company_id:     int
    name:           str
    role:           Optional[str]
    email:          Optional[str]
    linkedin:       Optional[str]
    created_at:     datetime

class ContactListResponse(BaseModel):
    total:          int
    contacts:       list[ContactResponse]
    page:           int
    size:           int


# ─── INTERVIEW ────────────────────────────────────────────────

class InterviewCreate(BaseModel):
    application_id:     int             = Field(..., gt=0)
    round:              int             = Field(..., ge=1)
    interview_date:     datetime
    interview_type:     InterviewType
    notes:              Optional[str]   = Field(None, max_length=1000)
    # outcome defaults to Pending — no need to send on create

class InterviewUpdate(BaseModel):
    round:              Optional[int]               = Field(None, ge=1)
    interview_date:     Optional[datetime]          = None
    interview_type:     Optional[InterviewType]     = None
    outcome:            Optional[InterviewOutcome]  = None
    notes:              Optional[str]               = Field(None, max_length=1000)

class InterviewResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id:                 int
    application_id:     int
    round:              int
    interview_date:     datetime
    interview_type:     InterviewType
    outcome:            InterviewOutcome
    notes:              Optional[str]
    created_at:         datetime

class InterviewListResponse(BaseModel):
    total:              int
    interviews:         list[InterviewResponse]
    page:               int
    size:               int