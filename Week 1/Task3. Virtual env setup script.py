# """
# 3. Virtual env setup script
# Write a shell-like checklist as a Python file that prints setup instructions customised for the current OS.
# logic
# Output (on Windows):
# 1. python -m venv .venv
# 2. r.venv\Scripts\activate
# 3. pip install requests

# Output (on macOS/Linux):
# 1. python -m venv .venv
# 2. source .venv/bin/activate
# 3. pip install requests

# """

import sys

steps = [
    "python -m venv .venv",
    r".venv\Scripts\activate" if sys.platform == "win32" else "source .venv/bin/activate",
    "pip install requests"
]

for i, step in enumerate(steps, 1):
    print(f"{i}. {step}")