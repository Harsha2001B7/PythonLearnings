# security.py
# SQL safety validation
 
import re
from typing import Tuple
 
# These keywords are NEVER allowed in generated SQL
DANGEROUS_KEYWORDS = [
    'DROP', 'DELETE', 'TRUNCATE', 'ALTER', 'CREATE', 'INSERT',
    'UPDATE', 'EXEC', 'EXECUTE', 'xp_', 'sp_', '--', '/*', '*/',
    'OPENROWSET', 'OPENDATASOURCE', 'BULK', 'SHUTDOWN', 'RECONFIGURE',
]
 
def validate_sql_safety(sql: str) -> Tuple[bool, str]:
    """
    Validate that generated SQL is safe to execute.
    Returns (is_safe, reason).
    """
    sql_upper = sql.upper()
 
    # Rule 1: Only allow SELECT statements
    stripped = sql_upper.strip()
    if not stripped.startswith('SELECT') and not stripped.startswith('WITH'):
        return False, 'Only SELECT and CTE (WITH) queries are allowed'
 
    # Rule 2: Check for dangerous keywords
    for keyword in DANGEROUS_KEYWORDS:
        if keyword.upper() in sql_upper:
            return False, f'Dangerous keyword detected: {keyword}'
 
    # Rule 3: Check for subquery attacks
    if sql_upper.count('SELECT') > 3:
        return False, 'Too many nested SELECT statements - possible injection'
 
    # Rule 4: Check for UNION attacks (common SQL injection vector)
    if 'UNION' in sql_upper:
        return False, 'UNION statements are not allowed'
 
    return True, 'SQL is safe'
 
 
def sanitize_table_names(sql: str, allowed_tables: list) -> Tuple[bool, str]:
    """
    Check that the SQL only references allowed tables.
    """
    sql_lower = sql.lower()
    # Find all potential table names after FROM and JOIN keywords
    from_pattern = re.compile(r'(?:from|join)\s+([\w]+)', re.IGNORECASE)
    table_names = from_pattern.findall(sql)
    for table in table_names:
        if table.lower() not in [t.lower() for t in allowed_tables]:
            return False, f'Table "{table}" is not in the allowed list'
    return True, 'Tables are valid'
