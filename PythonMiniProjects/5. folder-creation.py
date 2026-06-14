import os

# Your existing base folder
base = r"C:\Users\renuk\PythonLearnings\FastAPIProjects\school-report-api"

# Files + folders to create
files = [
    "main.py",
    "database.py",
    ".env",

    "models/user.py",
    "models/student.py",

    "schemas/auth_schema.py",
    "schemas/student_schema.py",

    "repositories/user_repository.py",
    "repositories/student_repository.py",

    "services/auth_service.py",
    "services/report_service.py",

    "routers/auth_router.py",
    "routers/report_router.py",

    "auth/jwt_handler.py",
    "auth/password_handler.py",
    "auth/dependencies.py",

    "utils/constants.py"
]


for file in files:
    path = os.path.join(base, file)

    # create folder if not exists
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # create file if not exists
    with open(path, "w") as f:
        pass

print("✅ Project structure created successfully")