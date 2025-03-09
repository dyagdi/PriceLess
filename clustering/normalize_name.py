import psycopg2
import re
import unicodedata
import pandas as pd
from decouple import config

# Normalization function for product names
def normalize_product_name(name):
    if not name or not isinstance(name, str):
        return None
        
    # Convert to lowercase
    name = name.lower()
    
    # Normalize accents and special characters
    name = unicodedata.normalize('NFKD', name).encode('ASCII', 'ignore').decode('ASCII')
    
    # Replace common abbreviations and standardize terms
    replacements = {
        'gr': 'g',       # Standardize gram units
        'lt': 'l',       # Standardize liter units
        'ml.': 'ml',     # Remove period from ml
        'g.': 'g',       # Remove period from g
        'kg.': 'kg',     # Remove period from kg
        'adet': 'ad',    # Standardize piece/count
        ' x ': 'x',      # Standardize multiplication symbol
        'pkt': 'paket',  # Expand package abbreviation
    }
    
    for old, new in replacements.items():
        name = name.replace(old, new)
    
    # Standardize units: Insert a space between numbers and letters
    name = re.sub(r'(\d)([a-z])', r'\1 \2', name)
    name = re.sub(r'([a-z])(\d)', r'\1 \2', name)
    
    # Standardize common product size formats
    # e.g., "100g" -> "100 g", "2x500ml" -> "2 x 500 ml"
    name = re.sub(r'(\d+)x(\d+)', r'\1 x \2', name)
    name = re.sub(r'(\d+)(ml|l|g|kg)', r'\1 \2', name)
    
    # Remove brand-specific suffixes that don't help with matching
    name = re.sub(r'\b(inc|ltd|co|gida|market)\b', '', name)
    
    # Trim whitespace
    name = name.strip()
    
    # Replace extra spaces with a single space
    name = re.sub(r'\s+', ' ', name)
    
    # Remove special characters (keep alphanumeric and spaces)
    name = re.sub(r'[^a-z0-9\s]', '', name)
    
    # Sort words for consistency
    name = ' '.join(sorted(name.split()))
    
    return name

# Connect to the PostgreSQL database
try:
    conn = psycopg2.connect(
        host=config('DATABASE_HOST', default='localhost'),
        database=config('DATABASE_NAME'),
        user=config('DATABASE_USER'),
        password=config('DATABASE_PASSWORD'),
        port=config('DATABASE_PORT', default='5432')
    )
    print("Database connection successful!")
    cursor = conn.cursor()
    
    # Get a list of all tables in the database
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
    """)
    tables = cursor.fetchall()
    tables = [table[0] for table in tables]
    
    print(f"Found {len(tables)} tables in the database")
    
    # Filter tables to only include market product tables
    market_tables = [table for table in tables if table.endswith('_products')]
    print(f"Found {len(market_tables)} market product tables: {market_tables}")
    
    # Process each market table
    for table in market_tables:
        print(f"Processing table: {table}")
        
        # Check if the normalized_name column exists
        cursor.execute(f"""
            SELECT column_name 
            FROM information_schema.columns 
            WHERE table_name = '{table}'
        """)
        columns = cursor.fetchall()
        column_names = [column[0] for column in columns]
        
        # Add normalized_name column if it doesn't exist
        if 'normalized_name' not in column_names:
            try:
                cursor.execute(f"ALTER TABLE {table} ADD COLUMN normalized_name TEXT;")
                conn.commit()
                print(f"Added normalized_name column to {table}")
            except Exception as e:
                print(f"Error adding column to {table}: {e}")
                continue
        
        # Check if the table has a name column
        if 'name' not in column_names:
            print(f"Table {table} does not have a name column, skipping")
            continue
        
        # Fetch all rows from the table to normalize names
        try:
            cursor.execute(f"SELECT id, name FROM {table};")
            rows = cursor.fetchall()
            print(f"Found {len(rows)} products in {table}")
        except Exception as e:
            print(f"Error fetching data from {table}: {e}")
            continue
        
        # Normalize product names and update the database
        update_count = 0
        for id, name in rows:
            if name:  # Ensure name is not None
                normalized_name = normalize_product_name(name)
                cursor.execute(f"UPDATE {table} SET normalized_name = %s WHERE id = %s;", 
                              (normalized_name, id))
                update_count += 1
                
                # Commit every 1000 updates to avoid transaction bloat
                if update_count % 1000 == 0:
                    conn.commit()
                    print(f"Committed {update_count} updates so far")
        
        conn.commit()
        print(f"Updated {update_count} products in {table}")
        
        # Verify the updates by fetching a sample of rows
        try:
            cursor.execute(f"SELECT name, normalized_name FROM {table} LIMIT 5;")
            updated_rows = cursor.fetchall()
            print("Sample of normalized names:")
            for row in updated_rows:
                print(f"Original: {row[0]} -> Normalized: {row[1]}")
        except Exception as e:
            print(f"Error verifying updates in {table}: {e}")
    
    # Close the connection
    cursor.close()
    conn.close()
    print("Normalization complete")
    
except Exception as e:
    print(f"Database connection error: {e}")
    import traceback
    traceback.print_exc()
