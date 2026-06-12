# routes.py
 
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from database import get_db
from models import QuestionRequest, QuestionResponse
from ai_service import generate_sql
from db_service import get_database_schema, execute_sql
from security import validate_sql_safety, sanitize_table_names
from config import settings
 
router = APIRouter(prefix='/api', tags=['AI SQL Assistant'])
 
@router.post('/ask', response_model=QuestionResponse)
def ask_question(
    request: QuestionRequest,
    db: Session = Depends(get_db)
):
    """
    Main endpoint: Takes an English question, returns query results.
    Pipeline: Question → Schema → Prompt → OpenAI → SQL → Validate → Execute → Results
    """
 
    # ── Step 1: Get database schema ───────────────────────────
    schema = get_database_schema()
 
    # ── Step 2: Generate SQL using AI ─────────────────────────
    ai_result = generate_sql(request.question, schema)
    if not ai_result['success']:
        raise HTTPException(
            status_code=422,
            detail=f'Could not generate SQL: {ai_result["error"]}'
        )
 
    generated_sql = ai_result['sql']
 
    # ── Step 3: Validate SQL safety ───────────────────────────
    is_safe, safety_message = validate_sql_safety(generated_sql)
    if not is_safe:
        raise HTTPException(
            status_code=403,
            detail=f'Generated SQL failed safety check: {safety_message}'
        )
 
    # ── Step 4: Validate allowed tables ───────────────────────
    tables_valid, table_message = sanitize_table_names(
        generated_sql, settings.allowed_tables_list
    )
    if not tables_valid:
        raise HTTPException(
            status_code=403,
            detail=f'SQL references unauthorized table: {table_message}'
        )
 
    # ── Step 5: Execute SQL ────────────────────────────────────
    db_result = execute_sql(generated_sql, db)
    if not db_result['success']:
        raise HTTPException(
            status_code=500,
            detail=f'SQL execution failed: {db_result["error"]}'
        )
 
    # ── Step 6: Return response ────────────────────────────────
    return QuestionResponse(
        question=request.question,
        sql=generated_sql if request.show_sql else None,
        rows=db_result['rows'],
        row_count=db_result['row_count'],
        columns=db_result['columns'],
        tokens_used=ai_result.get('tokens_used'),
        success=True
    )
 
 
@router.get('/schema')
def get_schema():
    """Returns the database schema - useful for debugging"""
    return {'schema': get_database_schema()}
 
 
@router.get('/health')
def health_check(db: Session = Depends(get_db)):
    """Health check - tests database connectivity"""
    try:
        from sqlalchemy import text
        db.execute(text('SELECT 1'))
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "database": str(e)}
