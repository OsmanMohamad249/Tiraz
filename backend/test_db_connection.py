import psycopg2
import os

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://qeyafa:qeyafa_password@localhost:5433/qeyafa_db")

try:
    conn = psycopg2.connect(DATABASE_URL)
    print("Connection to database successful.")
    conn.close()
except Exception as e:
    print(f"Database connection failed: {e}")
