import psycopg2
from decouple import config

try:
    print("Attempting to connect to database...")
    conn = psycopg2.connect(
        host=config('DATABASE_HOST', default='localhost'),
        database=config('DATABASE_NAME'),
        user=config('DATABASE_USER'),
        password=config('DATABASE_PASSWORD'),
        port=config('DATABASE_PORT', default='5432')
    )
    print("Connection successful!")
    
    # Try to create a test table
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS test_connection (
            id SERIAL PRIMARY KEY,
            test_column TEXT
        )
    """)
    conn.commit()
    print("Test table created successfully!")
    
    # Clean up
    conn.close()
    
except Exception as e:
    print(f"Error: {e}") 