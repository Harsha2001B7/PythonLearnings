from typing import Optional, List, Dict
from models import EmployeeCreate, EmployeeUpdate, EmployeeResponse
from exceptions import EmployeeNotFoundException
from datetime import date

class EmployeeRepository:
    def __init__(self):
        self._storage: Dict[int,dict] = {}
        self._next_id: int = 1

    def create(self, employee_data: EmployeeCreate) -> EmployeeResponse:
        employee_dict = {
            'id': self._next_id,
            'name': employee_data.name,
            'department': employee_data.department.value,
            'salary': employee_data.salary,
            'email': employee_data.email,
            'hire_date': employee_data.hire_date or date.today()
        }
        self._storage[self._next_id] = employee_dict
        self._next_id += 1
        return EmployeeResponse(**employee_dict)
    
    def get_by_id(self, employee_id: int) -> Optional[EmployeeResponse]:
        employee_dict = self._storage.get(employee_id)
        if employee_dict is None:
            raise EmployeeNotFoundException(employee_id)
        return EmployeeResponse(**employee_dict)
    
    def get_all(
            self,
            department: Optional[str] = None,
            skip: int = 0,
            limit: int = 10
    ) -> tuple[List[EmployeeResponse], int]:
        all_records = list(self._storage.values())
        if department:
            all_records = [record for record in all_records if record['department'].lower() == department.lower()]
        total = len(all_records)
        paginated_records = all_records[skip:skip+limit]
        return [EmployeeResponse(**record) for record in paginated_records], total
    
    def update(self, employee_id: int, update_data: EmployeeUpdate) -> Optional[EmployeeResponse]:
        employee_dict = self._storage.get(employee_id)
        if employee_dict is None:
            raise EmployeeNotFoundException(employee_id)        
        update_fields = update_data.model_dump(exclude_none=True)
        for key, value in update_fields.items():
            employee_dict[key] = value
        self._storage[employee_id] = employee_dict
        return EmployeeResponse(**employee_dict)
    def delete(self, employee_id: int) -> Optional[bool]:
        if employee_id not in self._storage:
            raise EmployeeNotFoundException(employee_id)
        del self._storage[employee_id]
        return True
    def email_exists(self, email: str) -> bool:
        return any(record['email'].lower() == email.lower() for record in self._storage.values())

employee_repo = EmployeeRepository()


