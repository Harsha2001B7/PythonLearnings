from typing import Optional
from models import EmployeeCreate, EmployeeUpdate, EmployeeResponse, EmployeeListResponse
from repository import employee_repo
from exceptions import EmployeeNotFoundException, DuplicateEmailException, InvalidSalaryError

class EmployeeService:
    def create_employee(self, employee_data: EmployeeCreate) -> EmployeeResponse:
        if employee_repo.email_exists(employee_data.email):
            raise DuplicateEmailException(employee_data.email)
        return employee_repo.create(employee_data)

    def get_employee(self, employee_id: int) -> Optional[EmployeeResponse]:
        return employee_repo.get_by_id(employee_id)
    
    def get_all_employees(
            self,
            department: Optional[str] = None,
            page: int = 1,
            page_size: int = 10
    ) -> EmployeeListResponse:
        skip = (page - 1) * page_size
        employees, total = employee_repo.get_all(department, skip, page_size)
        return EmployeeListResponse(
            total=total,
            employees=employees,
            page=page,
            page_size=page_size
        )
    
    def update_employee(self, employee_id: int, update_data: EmployeeUpdate) -> Optional[EmployeeResponse]:
        self.get_employee(employee_id)  # Check if employee exists, will raise exception if not
        if update_data.email is not None and employee_repo.email_exists(update_data.email):
            raise DuplicateEmailException(update_data.email)
        updated = employee_repo.update(employee_id, update_data)
        return updated
    
    def delete_employee(self, employee_id: int) -> Optional[bool]:
        self.get_employee(employee_id)  # Check if employee exists, will raise exception if not
        return employee_repo.delete(employee_id)

employee_service = EmployeeService()