import psycopg2
import pandas as pd
import numpy as np
from decouple import config
import psycopg2.extras

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
    
    # Use RealDictCursor to get results as dictionaries
    cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
    
    # Get a list of all tables in the database
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public'
    """)
    tables = cursor.fetchall()
    tables = [table['table_name'] for table in tables]
    
    # Filter tables to only include market product tables
    market_tables = [table for table in tables if table.endswith('_products')]
    print(f"Found {len(market_tables)} market product tables: {market_tables}")
    
    # Step 1: Fetch all products with canonical names from all market tables
    all_products = []
    
    for table in market_tables:
        try:
            # Extract market name from table name
            market_name = table.split('_')[0]
            
            # Check if the table has canonical_name column
            cursor.execute(f"""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = '{table}'
            """)
            columns = cursor.fetchall()
            column_names = [column['column_name'] for column in columns]
            
            if 'canonical_name' not in column_names:
                print(f"Table {table} does not have canonical_name column, skipping")
                continue
            
            # Fetch products with canonical names
            query = f"""
            SELECT 
                name, 
                normalized_name, 
                canonical_name,
                price,
                CASE 
                    WHEN in_stock = 'TRUE' OR in_stock = 'Yes' OR in_stock = '1' OR in_stock = TRUE THEN 1
                    ELSE 0
                END as in_stock,
                product_link,
                '{market_name}' as market_name
            FROM {table} 
            WHERE canonical_name IS NOT NULL AND price IS NOT NULL;
            """
            
            cursor.execute(query)
            products = cursor.fetchall()
            products_df = pd.DataFrame(products)
            print(f"Found {len(products_df)} products with canonical names in {table}")
            all_products.append(products_df)
        
        except Exception as e:
            print(f"Error processing table {table}: {e}")
    
    # Combine all products into a single DataFrame
    if all_products:
        products_df = pd.concat(all_products, ignore_index=True)
        print(f"Total products with canonical names: {len(products_df)}")
    else:
        print("No products found with canonical names")
        exit()
    
    # Ensure price is numeric and drop NaN values
    products_df['price'] = pd.to_numeric(products_df['price'], errors='coerce')
    products_df = products_df.dropna(subset=['price', 'canonical_name'])
    print(f"After dropping NaN values: {len(products_df)} products")
    
    # Step 2: Find the cheapest product for each canonical name
    # Use a safer approach to find the minimum price for each canonical name
    cheapest_products = []
    
    for name, group in products_df.groupby('canonical_name'):
        if not pd.isna(name) and len(group) > 0:
            min_price_idx = group['price'].idxmin()
            if not pd.isna(min_price_idx):
                cheapest_products.append(products_df.loc[min_price_idx])
    
    # Convert to DataFrame
    cheapest_products_df = pd.DataFrame(cheapest_products)
    print(f"Found {len(cheapest_products_df)} unique products (by canonical name)")
    
    # Step 3: Save the cheapest products to CSV
    if len(cheapest_products_df) > 0:
        cheapest_products_df.to_csv("cheapest_products.csv", index=False)
        print("Saved cheapest products to cheapest_products.csv")
        
        # Step 4: Display a sample of the cheapest products
        print("\nSample of cheapest products:")
        pd.set_option('display.max_columns', None)
        pd.set_option('display.width', 1000)
        print(cheapest_products_df.head(10))
    else:
        print("No cheapest products found. Check your data for valid prices and canonical names.")
    
    # Close the connection
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Database connection error: {e}")
    import traceback
    traceback.print_exc() 