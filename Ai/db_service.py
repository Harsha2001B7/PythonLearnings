# db_service.py
 
from sqlalchemy.orm import Session
from sqlalchemy import text, inspect
from typing import Any, Dict, List
from database import engine
from config import settings
 
def get_database_schema() -> str:
    """
    Automatically reads the database schema and returns it as a
    formatted string for use in the AI prompt.
    This is like INFORMATION_SCHEMA in SQL Server.
    """
    inspector = inspect(engine)
    schema_text = []
 
    for table_name in settings.allowed_tables_list:
        try:
            columns = inspector.get_columns(table_name)
            col_defs = []
            for col in columns:
                col_type = str(col['type'])
                nullable = '' if col.get('nullable', True) else ' NOT NULL'
                col_defs.append(f"  {col['name']} {col_type}{nullable}")
            schema_text.append(f'Table: {table_name}')
            schema_text.append(',\n'.join(col_defs))
            schema_text.append('')
        except Exception:
            pass  # Skip tables that can't be introspected
 
    return '\n'.join(schema_text)
 
 
def execute_sql(
    sql: str,
    db: Session,
    max_rows: int = None
) -> Dict[str, Any]:
    """
    Execute a SELECT SQL query and return results as a list of dicts.
    SQL Server equivalent of: EXECUTE (@sql)
    """
    if max_rows is None:
        max_rows = settings.max_sql_rows
 
    try:
        # Execute the query using SQLAlchemy's text() for safety
        result = db.execute(text(sql))
 
        # Get column names
        columns = list(result.keys())
 
        # Fetch rows (up to max_rows)
        rows = result.fetchmany(max_rows)
 
        # Convert to list of dicts (like a SQL result set)
        data = [dict(zip(columns, row)) for row in rows]
 
        return {
            'success': True,
            'rows': data,
            'row_count': len(data),
            'columns': columns
        }
 
    except Exception as e:
        return {
            'success': False,
            'error': str(e),
            'rows': [],
            'row_count': 0
        }
