import psycopg2
import pandas as pd
from decouple import config
import psycopg2.extras
import sys

def get_input_with_default(prompt, default):
    """Get user input with a default value if empty."""
    user_input = input(f"{prompt} [{default}]: ")
    return user_input if user_input.strip() else default

def main():
    try:
        # Connect to the PostgreSQL database
        conn = psycopg2.connect(
            host=config('DATABASE_HOST', default='localhost'),
            database=config('DATABASE_NAME'),
            user=config('DATABASE_USER'),
            password=config('DATABASE_PASSWORD'),
            port=config('DATABASE_PORT', default='5432')
        )
        print("Database connection successful!")
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
        
        # Ask user for filtering criteria
        filter_option = input("Filter canonical names by (1: small clusters, 2: specific market, 3: search term): ")
        
        query_conditions = []
        query_params = []
        
        if filter_option == "1":
            # Option 1: Find canonical names with small clusters
            min_products = int(input("Minimum number of products in a cluster: "))
            max_products = int(input("Maximum number of products in a cluster: "))
            
            # Create a CTE to count products per canonical name
            query = """
            WITH product_counts AS (
                SELECT canonical_name, COUNT(*) as product_count
                FROM (
            """
            
            for i, table in enumerate(market_tables):
                if i > 0:
                    query += " UNION ALL "
                query += f"SELECT canonical_name FROM {table} WHERE canonical_name IS NOT NULL"
            
            query += """
                ) AS all_products
                GROUP BY canonical_name
                HAVING COUNT(*) BETWEEN %s AND %s
            )
            SELECT pc.canonical_name, pc.product_count
            FROM product_counts pc
            ORDER BY pc.product_count, pc.canonical_name
            LIMIT 100;
            """
            
            query_params = [min_products, max_products]
            
        elif filter_option == "2":
            # Option 2: Find canonical names in a specific market
            print("Available markets:")
            for i, table in enumerate(market_tables):
                market_name = table.split('_')[0]
                print(f"{i+1}: {market_name}")
            
            market_idx = int(input("Select market (number): ")) - 1
            if market_idx < 0 or market_idx >= len(market_tables):
                print("Invalid market selection")
                return
            
            selected_table = market_tables[market_idx]
            
            query = f"""
            SELECT canonical_name, COUNT(*) as product_count
            FROM {selected_table}
            WHERE canonical_name IS NOT NULL
            GROUP BY canonical_name
            ORDER BY product_count
            LIMIT 100;
            """
            
        elif filter_option == "3":
            # Option 3: Search by term
            search_term = input("Enter search term: ")
            
            query = """
            SELECT canonical_name, COUNT(*) as product_count
            FROM (
            """
            
            for i, table in enumerate(market_tables):
                if i > 0:
                    query += " UNION ALL "
                query += f"SELECT canonical_name FROM {table} WHERE canonical_name IS NOT NULL"
            
            query += """
            ) AS all_products
            WHERE canonical_name LIKE %s
            GROUP BY canonical_name
            ORDER BY canonical_name
            LIMIT 100;
            """
            
            query_params = [f"%{search_term}%"]
            
        else:
            print("Invalid option")
            return
        
        # Execute the query
        cursor.execute(query, query_params)
        canonical_names = cursor.fetchall()
        
        if not canonical_names:
            print("No canonical names found matching the criteria")
            return
        
        print(f"Found {len(canonical_names)} canonical names")
        
        # Process each canonical name
        for i, row in enumerate(canonical_names):
            canonical_name = row['canonical_name']
            product_count = row['product_count']
            
            print(f"\n[{i+1}/{len(canonical_names)}] Canonical name: {canonical_name}")
            print(f"Number of products: {product_count}")
            
            # Fetch sample products with this canonical name
            sample_products = []
            for table in market_tables:
                market_name = table.split('_')[0]
                cursor.execute(f"""
                    SELECT name, price, '{market_name}' as market
                    FROM {table}
                    WHERE canonical_name = %s
                    LIMIT 3
                """, [canonical_name])
                sample_products.extend(cursor.fetchall())
            
            # Display sample products
            print("Sample products:")
            for product in sample_products:
                print(f"- {product['name']} ({product['market']}, {product['price']})")
            
            # Ask if the canonical name should be fixed
            fix_option = input("Fix this canonical name? (y/n/q to quit): ").lower()
            
            if fix_option == 'q':
                break
            elif fix_option == 'y':
                new_canonical = get_input_with_default("Enter new canonical name", canonical_name)
                
                if new_canonical != canonical_name:
                    # Update all tables with the new canonical name
                    for table in market_tables:
                        cursor.execute(f"""
                            UPDATE {table}
                            SET canonical_name = %s
                            WHERE canonical_name = %s
                        """, [new_canonical, canonical_name])
                    
                    conn.commit()
                    print(f"Updated canonical name to: {new_canonical}")
        
        # Close the connection
        cursor.close()
        conn.close()
        print("\nCanonical name fixing complete")
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main() 