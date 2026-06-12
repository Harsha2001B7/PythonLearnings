from sqlalchemy.orm import Session
from typing import Optional
from db_models import ApplicationStatus
from models import (
    CompanyCreate, CompanyUpdate, CompanyResponse, CompanyListResponse,
    ApplicationCreate, ApplicationUpdate, ApplicationResponse, ApplicationListResponse,
    ContactCreate, ContactUpdate, ContactResponse, ContactListResponse,
    InterviewCreate, InterviewUpdate, InterviewResponse, InterviewListResponse
)
from repository import company_repo, application_repo, contact_repo, interview_repo
from exceptions import (
    CompanyNotFoundException, CompanyAlreadyExistsException,
    ApplicationNotFoundException, InvalidStatusTransitionException,
    ContactNotFoundException, InterviewNotFoundException,
    ApplicationNotInInterviewStageException
)

# Valid status transitions — the core business logic of this project
# Key = current status, Value = allowed next statuses
VALID_TRANSITIONS = {
    ApplicationStatus.Applied:    [ApplicationStatus.Screening,  ApplicationStatus.Rejected],
    ApplicationStatus.Screening:  [ApplicationStatus.Interview,  ApplicationStatus.Rejected],
    ApplicationStatus.Interview:  [ApplicationStatus.Offer,      ApplicationStatus.Rejected],
    ApplicationStatus.Offer:      [ApplicationStatus.Accepted,   ApplicationStatus.Rejected],
    ApplicationStatus.Accepted:   [],
    ApplicationStatus.Rejected:   [],
}


class CompanyService:

    def create_company(self, db: Session, data: CompanyCreate) -> CompanyResponse:
        if company_repo.name_exists(db, data.name):
            raise CompanyAlreadyExistsException(data.name)
        return company_repo.create(db, data)

    def get_company(self, db: Session, company_id: int) -> CompanyResponse:
        company = company_repo.get_by_id(db, company_id)
        if company is None:
            raise CompanyNotFoundException(company_id)
        return company

    def get_all_companies(self, db: Session, page: int = 1, page_size: int = 10) -> CompanyListResponse:
        skip = (page - 1) * page_size
        companies, total = company_repo.get_all(db, skip, page_size)
        return CompanyListResponse(total=total, companies=companies, page=page, size=page_size)

    def update_company(self, db: Session, company_id: int, data: CompanyUpdate) -> CompanyResponse:
        self.get_company(db, company_id)
        if data.name and company_repo.name_exists(db, data.name, exclude_id=company_id):
            raise CompanyAlreadyExistsException(data.name)
        return company_repo.update(db, company_id, data)

    def delete_company(self, db: Session, company_id: int) -> None:
        self.get_company(db, company_id)
        company_repo.delete(db, company_id)


class ApplicationService:

    def create_application(self, db: Session, data: ApplicationCreate) -> ApplicationResponse:
        # Validate company exists before creating application
        company = company_repo.get_by_id(db, data.company_id)
        if company is None:
            raise CompanyNotFoundException(data.company_id)
        return application_repo.create(db, data)

    def get_application(self, db: Session, application_id: int) -> ApplicationResponse:
        app = application_repo.get_by_id(db, application_id)
        if app is None:
            raise ApplicationNotFoundException(application_id)
        return app

    def get_all_applications(
        self, db: Session,
        status: Optional[ApplicationStatus] = None,
        company_id: Optional[int] = None,
        page: int = 1, page_size: int = 10
    ) -> ApplicationListResponse:
        skip = (page - 1) * page_size
        apps, total = application_repo.get_all(db, status, company_id, skip, page_size)
        return ApplicationListResponse(total=total, applications=apps, page=page, size=page_size)

    def update_application(self, db: Session, application_id: int, data: ApplicationUpdate) -> ApplicationResponse:
        # Get raw ORM object to check current status
        current = application_repo.get_raw(db, application_id)
        if current is None:
            raise ApplicationNotFoundException(application_id)

        # Validate status transition if status is being changed
        if data.status and data.status != current.status:
            allowed = VALID_TRANSITIONS.get(current.status, [])
            if data.status not in allowed:
                raise InvalidStatusTransitionException(current.status.value, data.status.value)

        return application_repo.update(db, application_id, data)

    def delete_application(self, db: Session, application_id: int) -> None:
        self.get_application(db, application_id)
        application_repo.delete(db, application_id)


class ContactService:

    def create_contact(self, db: Session, data: ContactCreate) -> ContactResponse:
        company = company_repo.get_by_id(db, data.company_id)
        if company is None:
            raise CompanyNotFoundException(data.company_id)
        return contact_repo.create(db, data)

    def get_contact(self, db: Session, contact_id: int) -> ContactResponse:
        contact = contact_repo.get_by_id(db, contact_id)
        if contact is None:
            raise ContactNotFoundException(contact_id)
        return contact

    def get_all_contacts(
        self, db: Session,
        company_id: Optional[int] = None,
        page: int = 1, page_size: int = 10
    ) -> ContactListResponse:
        skip = (page - 1) * page_size
        contacts, total = contact_repo.get_all(db, company_id, skip, page_size)
        return ContactListResponse(total=total, contacts=contacts, page=page, size=page_size)

    def update_contact(self, db: Session, contact_id: int, data: ContactUpdate) -> ContactResponse:
        self.get_contact(db, contact_id)
        return contact_repo.update(db, contact_id, data)

    def delete_contact(self, db: Session, contact_id: int) -> None:
        self.get_contact(db, contact_id)
        contact_repo.delete(db, contact_id)


class InterviewService:

    def create_interview(self, db: Session, data: InterviewCreate) -> InterviewResponse:
        # Application must exist
        app = application_repo.get_raw(db, data.application_id)
        if app is None:
            raise ApplicationNotFoundException(data.application_id)
        # Application must be in Interview status to log an interview
        if app.status != ApplicationStatus.Interview:
            raise ApplicationNotInInterviewStageException(data.application_id)
        return interview_repo.create(db, data)

    def get_interview(self, db: Session, interview_id: int) -> InterviewResponse:
        interview = interview_repo.get_by_id(db, interview_id)
        if interview is None:
            raise InterviewNotFoundException(interview_id)
        return interview

    def get_all_interviews(
        self, db: Session,
        application_id: Optional[int] = None,
        page: int = 1, page_size: int = 10
    ) -> InterviewListResponse:
        skip = (page - 1) * page_size
        interviews, total = interview_repo.get_all(db, application_id, skip, page_size)
        return InterviewListResponse(total=total, interviews=interviews, page=page, size=page_size)

    def update_interview(self, db: Session, interview_id: int, data: InterviewUpdate) -> InterviewResponse:
        self.get_interview(db, interview_id)
        return interview_repo.update(db, interview_id, data)

    def delete_interview(self, db: Session, interview_id: int) -> None:
        self.get_interview(db, interview_id)
        interview_repo.delete(db, interview_id)


# Singletons
company_service     = CompanyService()
application_service = ApplicationService()
contact_service     = ContactService()
interview_service   = InterviewService()