import os

# Root project folder
base = r"C:\Users\renuk\PythonLearnings\ai_task_hub\ai_task_hub_backend"

# Files to create
files = [
    "app/main.py",

    "app/core/config.py",
    "app/core/security.py",

    "app/database/db.py",

    "app/models/user.py",
    "app/models/task.py",

    "app/schemas/user.py",
    "app/schemas/task.py",

    "app/routers/auth_router.py",
    "app/routers/task_router.py",
    "app/routers/dashboard_router.py",

    "app/services/auth_service.py",
    "app/services/task_service.py",

    "app/dependencies/auth_dependency.py",

    "requirements.txt"
]

# Folders where __init__.py should be created
folders = [
    "app",
    "app/core",
    "app/database",
    "app/models",
    "app/schemas",
    "app/routers",
    "app/services",
    "app/dependencies"
]


# Create folders + files
for file in files:
    path = os.path.join(base, file)

    # Create parent directories if needed
    os.makedirs(os.path.dirname(path), exist_ok=True)

    # Create file only if it doesn't exist
    if not os.path.exists(path):
        with open(path, "w", encoding="utf-8") as f:
            pass


# Create __init__.py in every folder except root
for folder in folders:
    init_path = os.path.join(base, folder, "__init__.py")

    if not os.path.exists(init_path):
        with open(init_path, "w", encoding="utf-8") as f:
            pass


print("✅ ai_task_hub_backend project structure created successfully")