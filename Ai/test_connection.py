# test_connection.py
import pyodbc
conn = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=RENUKAREDDYPC\\MSSQLSERVER02;"  # double backslash in Python strings
    "DATABASE=JobTrackerDB;"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)
print("✅ Connected!", conn.getinfo(pyodbc.SQL_SERVER_NAME))
conn.close()