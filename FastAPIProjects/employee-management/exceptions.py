class EmployeeNotFoundException(Exception):
    def __init__(self, employee_id: int):
        self.employee_id = employee_id
        super().__init__(f"Employee with id {employee_id} not found")

class DuplicateEmailException(Exception):
    def __init__(self, email: str):
        self.email = email
        super().__init__(f"Employee with email {email} already exists")

class InvalidSalaryError(Exception):
    def __init__(self, salary: str):
        self.salary = salary
        super().__init__(f"Invalid salary: {salary}. Salary must be greater than 0")        