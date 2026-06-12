# test_gemini.py
from google import genai

client = genai.Client(api_key="AQ.Ab8RN6KCbu8xWAOANYyxEfQ2-uTs5iofyZvA7u_7JQOz4ee4Kg")

response = client.models.generate_content(
    model="gemini-2.0-flash",
    contents="Say hello"
)
print("✅ Connected!", response.text)