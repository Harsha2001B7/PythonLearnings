# ai_service.py

import re
from google import genai
from google.genai import types
from config import settings

# Initialize new Gemini client
client = genai.Client(api_key=settings.gemini_api_key)
MODEL = "gemini-2.5-flash-lite"

def build_sql_prompt(question: str, schema: str) -> str:
    return f'''You are an expert SQL Server T-SQL query generator.

Your job is to convert natural language questions into valid SQL Server SELECT queries.

Database Schema:
{schema}

Rules (STRICT - never violate these):
1. Generate ONLY SELECT statements. Never INSERT, UPDATE, DELETE, DROP, or ALTER.
2. Use proper SQL Server T-SQL syntax (use TOP instead of LIMIT, GETDATE() not NOW()).
3. Always qualify column names with table names (e.g., companies.name not just name).
4. For string comparisons, use UPPER() for case-insensitive matching.
5. Add a comment on the first line explaining what the query does.
6. Return ONLY the SQL query. No explanation, no markdown, no backticks.
7. If the question cannot be answered with the available schema, return:
   -- CANNOT_ANSWER: [brief explanation]

Examples:
Question: How many companies are there?
Answer: -- Count of all companies
SELECT COUNT(*) AS total_companies FROM companies

Question: List all applications for a specific company
Answer: -- Applications joined with company details
SELECT companies.name, applications.status, applications.applied_date
FROM applications
JOIN companies ON applications.company_id = companies.id
ORDER BY applications.applied_date DESC

Now answer this question:
Question: {question}
Answer:'''


def extract_sql_from_response(response_text: str) -> str:
    response_text = re.sub(r'```sql\s*', '', response_text)
    response_text = re.sub(r'```\s*', '', response_text)
    return response_text.strip()


def generate_sql(question: str, schema: str) -> dict:
    prompt = build_sql_prompt(question, schema)

    try:
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt,
            config=types.GenerateContentConfig(
                temperature=0,
                max_output_tokens=500
            )
        )

        sql = extract_sql_from_response(response.text)

        if sql.startswith('-- CANNOT_ANSWER'):
            reason = sql.replace('-- CANNOT_ANSWER:', '').strip()
            return {'success': False, 'sql': None, 'error': f'Cannot answer: {reason}'}

        return {
            'success': True,
            'sql': sql,
            'tokens_used': response.usage_metadata.total_token_count
        }

    except Exception as e:
        return {'success': False, 'sql': None, 'error': str(e)}