from sqlalchemy.orm import Session
from sqlalchemy import and_
from typing import Optional, List
from db_models import Employee, Department
from schemas import EmployeeCreate, EmployeeUpdate
from datetime import date
 
class EmployeeRepository:
 
    def create(self, db: Session, employee_data: EmployeeCreate) -> Employee:
        db_employee = Employee(
            name=employee_data.name,
            email=employee_data.email,
            salary=employee_data.salary,
            department_id=employee_data.department_id,
            hire_date=employee_data.hire_date or date.today()
        )
        db.add(db_employee)    
        db.commit()            
        db.refresh(db_employee) 
        return db_employee
 
    def get_by_id(self, db: Session, employee_id: int) -> Optional[Employee]:
        return db.query(Employee).filter(Employee.id == employee_id).first()
 
    def get_all(
        self, db: Session,
        department_id: Optional[int] = None,
        is_active: Optional[bool] = None,
        skip: int = 0,
        limit: int = 10
    ) -> tuple[List[Employee], int]:
        query = db.query(Employee)
        if department_id:
            query = query.filter(Employee.department_id == department_id)
        if is_active is not None:
            query = query.filter(Employee.is_active == is_active)
        total = query.count()   
        employees = query.offset(skip).limit(limit).all()  
        return employees, total
 
    def update(self, db: Session, employee_id: int, update_data: EmployeeUpdate) -> Optional[Employee]:
        db_employee = self.get_by_id(db, employee_id)
        if not db_employee:
            return None
        update_dict = update_data.dict(exclude_none=True)
        for field, value in update_dict.items():
            setattr(db_employee, field, value)  
        db.commit()
        db.refresh(db_employee)
        return db_employee
 
    def delete(self, db: Session, employee_id: int) -> bool:
        db_employee = self.get_by_id(db, employee_id)
        if not db_employee:
            return False
        db.delete(db_employee) 
        db.commit()            
        return True
 
    def email_exists(self, db: Session, email: str, exclude_id: Optional[int] = None) -> bool:
        query = db.query(Employee).filter(Employee.email == email)
        if exclude_id:
            query = query.filter(Employee.id != exclude_id)
        return query.first() is not None
 
employee_repo = EmployeeRepository()
