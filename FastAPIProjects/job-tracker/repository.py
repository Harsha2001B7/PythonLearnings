from typing import Optional
from sqlalchemy.orm import Session
from db_models import Company, Application, Contact, Interview, ApplicationStatus
from models import (
    CompanyCreate, CompanyUpdate, CompanyResponse,
    ApplicationCreate, ApplicationUpdate, ApplicationResponse,
    ContactCreate, ContactUpdate, ContactResponse,
    InterviewCreate, InterviewUpdate, InterviewResponse
)


class CompanyRepository:

    def create(self, db: Session, data: CompanyCreate) -> CompanyResponse:
        company = Company(**data.model_dump())
        db.add(company)
        db.commit()
        db.refresh(company)
        return CompanyResponse.model_validate(company)

    def get_by_id(self, db: Session, company_id: int) -> Optional[CompanyResponse]:
        company = db.query(Company).filter(Company.id == company_id).first()
        if company is None:
            return None
        return CompanyResponse.model_validate(company)

    def get_all(self, db: Session, skip: int = 0, limit: int = 10) -> tuple[list[CompanyResponse], int]:
        query = db.query(Company)
        total = query.count()
        companies = query.order_by(Company.id).offset(skip).limit(limit).all()
        return [CompanyResponse.model_validate(c) for c in companies], total

    def update(self, db: Session, company_id: int, data: CompanyUpdate) -> Optional[CompanyResponse]:
        company = db.query(Company).filter(Company.id == company_id).first()
        if company is None:
            return None
        for key, value in data.model_dump(exclude_none=True).items():
            setattr(company, key, value)
        db.commit()
        db.refresh(company)
        return CompanyResponse.model_validate(company)

    def delete(self, db: Session, company_id: int) -> bool:
        company = db.query(Company).filter(Company.id == company_id).first()
        if company is None:
            return False
        db.delete(company)
        db.commit()
        return True

    def name_exists(self, db: Session, name: str, exclude_id: Optional[int] = None) -> bool:
        query = db.query(Company).filter(Company.name == name)
        if exclude_id:
            query = query.filter(Company.id != exclude_id)
        return query.first() is not None


class ApplicationRepository:

    def create(self, db: Session, data: ApplicationCreate) -> ApplicationResponse:
        application = Application(**data.model_dump())
        db.add(application)
        db.commit()
        db.refresh(application)
        return ApplicationResponse.model_validate(application)

    def get_by_id(self, db: Session, application_id: int) -> Optional[ApplicationResponse]:
        app = db.query(Application).filter(Application.id == application_id).first()
        if app is None:
            return None
        return ApplicationResponse.model_validate(app)

    def get_raw(self, db: Session, application_id: int) -> Optional[Application]:
        # Returns raw ORM object — needed for status transition check in service
        return db.query(Application).filter(Application.id == application_id).first()

    def get_all(
        self, db: Session,
        status: Optional[ApplicationStatus] = None,
        company_id: Optional[int] = None,
        skip: int = 0, limit: int = 10
    ) -> tuple[list[ApplicationResponse], int]:
        query = db.query(Application)
        if status:
            query = query.filter(Application.status == status)
        if company_id:
            query = query.filter(Application.company_id == company_id)
        total = query.count()
        apps = query.order_by(Application.id).offset(skip).limit(limit).all()
        return [ApplicationResponse.model_validate(a) for a in apps], total

    def update(self, db: Session, application_id: int, data: ApplicationUpdate) -> Optional[ApplicationResponse]:
        app = db.query(Application).filter(Application.id == application_id).first()
        if app is None:
            return None
        for key, value in data.model_dump(exclude_none=True).items():
            setattr(app, key, value)
        db.commit()
        db.refresh(app)
        return ApplicationResponse.model_validate(app)

    def delete(self, db: Session, application_id: int) -> bool:
        app = db.query(Application).filter(Application.id == application_id).first()
        if app is None:
            return False
        db.delete(app)
        db.commit()
        return True


class ContactRepository:

    def create(self, db: Session, data: ContactCreate) -> ContactResponse:
        contact = Contact(**data.model_dump())
        db.add(contact)
        db.commit()
        db.refresh(contact)
        return ContactResponse.model_validate(contact)

    def get_by_id(self, db: Session, contact_id: int) -> Optional[ContactResponse]:
        contact = db.query(Contact).filter(Contact.id == contact_id).first()
        if contact is None:
            return None
        return ContactResponse.model_validate(contact)

    def get_all(
        self, db: Session,
        company_id: Optional[int] = None,
        skip: int = 0, limit: int = 10
    ) -> tuple[list[ContactResponse], int]:
        query = db.query(Contact)
        if company_id:
            query = query.filter(Contact.company_id == company_id)
        total = query.count()
        contacts = query.order_by(Contact.id).offset(skip).limit(limit).all()
        return [ContactResponse.model_validate(c) for c in contacts], total

    def update(self, db: Session, contact_id: int, data: ContactUpdate) -> Optional[ContactResponse]:
        contact = db.query(Contact).filter(Contact.id == contact_id).first()
        if contact is None:
            return None
        for key, value in data.model_dump(exclude_none=True).items():
            setattr(contact, key, value)
        db.commit()
        db.refresh(contact)
        return ContactResponse.model_validate(contact)

    def delete(self, db: Session, contact_id: int) -> bool:
        contact = db.query(Contact).filter(Contact.id == contact_id).first()
        if contact is None:
            return False
        db.delete(contact)
        db.commit()
        return True


class InterviewRepository:

    def create(self, db: Session, data: InterviewCreate) -> InterviewResponse:
        interview = Interview(**data.model_dump())
        db.add(interview)
        db.commit()
        db.refresh(interview)
        return InterviewResponse.model_validate(interview)

    def get_by_id(self, db: Session, interview_id: int) -> Optional[InterviewResponse]:
        interview = db.query(Interview).filter(Interview.id == interview_id).first()
        if interview is None:
            return None
        return InterviewResponse.model_validate(interview)

    def get_all(
        self, db: Session,
        application_id: Optional[int] = None,
        skip: int = 0, limit: int = 10
    ) -> tuple[list[InterviewResponse], int]:
        query = db.query(Interview)
        if application_id:
            query = query.filter(Interview.application_id == application_id)
        total = query.count()
        interviews = query.order_by(Interview.id).offset(skip).limit(limit).all()
        return [InterviewResponse.model_validate(i) for i in interviews], total

    def update(self, db: Session, interview_id: int, data: InterviewUpdate) -> Optional[InterviewResponse]:
        interview = db.query(Interview).filter(Interview.id == interview_id).first()
        if interview is None:
            return None
        for key, value in data.model_dump(exclude_none=True).items():
            setattr(interview, key, value)
        db.commit()
        db.refresh(interview)
        return InterviewResponse.model_validate(interview)

    def delete(self, db: Session, interview_id: int) -> bool:
        interview = db.query(Interview).filter(Interview.id == interview_id).first()
        if interview is None:
            return False
        db.delete(interview)
        db.commit()
        return True


# Singletons
company_repo     = CompanyRepository()
application_repo = ApplicationRepository()
contact_repo     = ContactRepository()
interview_repo   = InterviewRepository()