from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Enum as SAEnum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base
import enum


class ApplicationStatus(enum.Enum):
    Applied     = "Applied"
    Screening   = "Screening"
    Interview   = "Interview"
    Offer       = "Offer"
    Accepted    = "Accepted"
    Rejected    = "Rejected"


class InterviewType(enum.Enum):
    Phone       = "Phone"
    Technical   = "Technical"
    HR          = "HR"
    Final       = "Final"
    Other       = "Other"


class InterviewOutcome(enum.Enum):
    Passed      = "Passed"
    Failed      = "Failed"
    Pending     = "Pending"


class Company(Base):
    __tablename__ = "companies"

    id          = Column(Integer, primary_key=True, index=True)
    name        = Column(String(150), nullable=False, unique=True)
    website     = Column(String(255), nullable=True)
    location    = Column(String(150), nullable=True)
    industry    = Column(String(100), nullable=True)
    created_at  = Column(DateTime, server_default=func.now())

    applications = relationship("Application", back_populates="company")
    contacts     = relationship("Contact",     back_populates="company")


class Application(Base):
    __tablename__ = "applications"

    id              = Column(Integer, primary_key=True, index=True)
    company_id      = Column(Integer, ForeignKey("companies.id"), nullable=False)
    role            = Column(String(150), nullable=False)
    status          = Column(SAEnum(ApplicationStatus), nullable=False, default=ApplicationStatus.Applied)
    applied_date    = Column(DateTime, nullable=False, server_default=func.now())
    job_url         = Column(String(500), nullable=True)
    notes           = Column(String(1000), nullable=True)
    created_at      = Column(DateTime, server_default=func.now())

    company     = relationship("Company",   back_populates="applications")
    interviews  = relationship("Interview", back_populates="application")


class Contact(Base):
    __tablename__ = "contacts"

    id          = Column(Integer, primary_key=True, index=True)
    company_id  = Column(Integer, ForeignKey("companies.id"), nullable=False)
    name        = Column(String(150), nullable=False)
    role        = Column(String(150), nullable=True)
    email       = Column(String(150), nullable=True)
    linkedin    = Column(String(255), nullable=True)
    created_at  = Column(DateTime, server_default=func.now())

    company = relationship("Company", back_populates="contacts")


class Interview(Base):
    __tablename__ = "interviews"

    id              = Column(Integer, primary_key=True, index=True)
    application_id  = Column(Integer, ForeignKey("applications.id"), nullable=False)
    round           = Column(Integer, nullable=False, default=1)
    interview_date  = Column(DateTime, nullable=False)
    interview_type  = Column(SAEnum(InterviewType),    nullable=False)
    outcome         = Column(SAEnum(InterviewOutcome), nullable=False, default=InterviewOutcome.Pending)
    notes           = Column(String(1000), nullable=True)
    created_at      = Column(DateTime, server_default=func.now())

    application = relationship("Application", back_populates="interviews")