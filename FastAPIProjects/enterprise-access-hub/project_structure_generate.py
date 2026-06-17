import os

# Your existing base folder (already created)
base = r"C:\Users\renuk\PythonLearnings\FastAPIProjects\enterprise-access-hub"

# Files + folders to create
files = [
    "main.py",
    "database.py",
    ".env",

    # models
    "models/__init__.py",
    "models/base.py",
    "models/role.py",
    "models/user.py",
    "models/workspace.py",

    # schemas
    "schemas/__init__.py",
    "schemas/auth_schema.py",
    "schemas/user_schema.py",
    "schemas/workspace_schema.py",

    # repositories
    "repositories/__init__.py",
    "repositories/user_repository.py",
    "repositories/role_repository.py",
    "repositories/workspace_repository.py",

    # services
    "services/__init__.py",
    "services/auth_service.py",
    "services/workspace_service.py",

    # routers
    "routers/__init__.py",
    "routers/auth_router.py",
    "routers/workspace_router.py",
    "routers/user_router.py",

    # auth
    "auth/__init__.py",
    "auth/password_handler.py",
    "auth/jwt_handler.py",
    "auth/dependencies.py",

    # middleware
    "middleware/__init__.py",
    "middleware/request_timer.py",

    # exceptions
    "exceptions/__init__.py",
    "exceptions/app_exceptions.py",
    "exceptions/handlers.py",

    # seed
    "seed/__init__.py",
    "seed/seed_data.py",
]

# Create files and folders
for file in files:
    path = os.path.join(base, file)

    # Create folder if it doesn't exist
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # Create file if it doesn't exist
    if not os.path.exists(path):
        with open(path, "w", encoding="utf-8") as f:
            pass

print("✅ Enterprise Access Hub project structure created successfully")