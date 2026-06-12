# models.py
 
from pydantic import BaseModel, Field
from typing import Any, List, Optional, Dict
 
class QuestionRequest(BaseModel):
    """What the user sends"""
    question: str = Field(
        ...,
        min_length=5,
        max_length=500,
        description='Natural language question about your data'
    )
    show_sql: bool = Field(
        default=True,
        description='Whether to include the generated SQL in the response'
    )
 
class QueryResult(BaseModel):
    """A single result row"""
    pass
 
class QuestionResponse(BaseModel):
    """What the API returns"""
    question:    str
    sql:         Optional[str] = None     # The generated SQL (if show_sql=True)
    rows:        List[Dict[str, Any]] = []  # The query results
    row_count:   int = 0
    columns:     List[str] = []
    tokens_used: Optional[int] = None
    success:     bool
    error:       Optional[str] = None
