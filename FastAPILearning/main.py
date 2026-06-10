from fastapi import FastAPI
from pydantic import BaseModel
from typing import Optional

app = FastAPI(title = 'Employee API', version = '1.0.0')

class Employee(BaseModel):
    id:int
    name:str
    department:str
    salart:float
    email:Optional[str] = None

employee_db = []

@app.post("/employees",status_code=201)
def create_employee(employee: Employee):
    employee_db.append(employee)
    return employee


#GET -> Home Page
@app.get("/")
def home():
    return{
        "message":"Hello, FastAPI World!"
    }

@app.get("/employees")
def get_all_employees(
    department: Optional[str] = None,
    skip: int = 0,
    limit: int = 10
):
    all_employees = [
        {"id": 1, "name": "Ravi Kumar",   "department": "Engineering", "active": True},
        {"id": 2, "name": "Priya Sharma", "department": "HR",          "active": True},
        {"id": 3, "name": "Arjun Singh",  "department": "Engineering", "active": False},
    ]

    if department:
        filtered_employees = [e for e in all_employees if e['department'] == department]
        return filtered_employees
    return all_employees[skip : skip+limit]


@app.get("/employee/{id}")
def get_employee(id: int):
    employees =  {
       1: {"id":1, "name": "Ravi Kumar", "department": "Hr Department"},
       2: {"id":2, "name": "sundar", "department": "development" }
    }
    employee = employees.get(id)
    return employee
