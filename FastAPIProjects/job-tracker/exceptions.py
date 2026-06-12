class CompanyNotFoundException(Exception):
    def __init__(self, company_id: int):
        self.company_id = company_id
        super().__init__(f"Company with id {company_id} not found.")

class CompanyAlreadyExistsException(Exception):
    def __init__(self, name: str):
        self.name = name
        super().__init__(f"Company '{name}' already exists.")

class ApplicationNotFoundException(Exception):
    def __init__(self, application_id: int):
        self.application_id = application_id
        super().__init__(f"Application with id {application_id} not found.")

class InvalidStatusTransitionException(Exception):
    def __init__(self, current: str, new: str):
        super().__init__(f"Cannot transition status from '{current}' to '{new}'.")

class ContactNotFoundException(Exception):
    def __init__(self, contact_id: int):
        self.contact_id = contact_id
        super().__init__(f"Contact with id {contact_id} not found.")

class InterviewNotFoundException(Exception):
    def __init__(self, interview_id: int):
        self.interview_id = interview_id
        super().__init__(f"Interview with id {interview_id} not found.")

class ApplicationNotInInterviewStageException(Exception):
    def __init__(self, application_id: int):
        super().__init__(f"Application {application_id} must be in Interview status before logging an interview.")