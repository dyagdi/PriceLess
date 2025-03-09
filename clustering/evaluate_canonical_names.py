import psycopg2
import pandas as pd
from decouple import config
import matplotlib.pyplot as plt
import seaborn as sns
from collections import defaultdict
import random

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
    
    # Fetch all products with canonical names
    all_products = []
    
    for table in market_tables:
        try:
            # Extract market name from table name
            market_name = table.split('_')[0]
            
            # Fetch products with canonical names
            query = f"""
            SELECT 
                id, 
                name, 
                normalized_name, 
                canonical_name,
                price,
                '{market_name}' as market_name
            FROM {table} 
            WHERE canonical_name IS NOT NULL;
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
    
    # Group products by canonical name
    canonical_groups = products_df.groupby('canonical_name')
    
    # Calculate statistics
    group_sizes = canonical_groups.size()
    print(f"Number of unique canonical names: {len(group_sizes)}")
    print(f"Average products per canonical name: {group_sizes.mean():.2f}")
    print(f"Max products per canonical name: {group_sizes.max()}")
    
    # Plot distribution of group sizes
    plt.figure(figsize=(10, 6))
    sns.histplot(group_sizes, bins=30)
    plt.title('Distribution of Products per Canonical Name')
    plt.xlabel('Number of Products')
    plt.ylabel('Frequency')
    plt.savefig('canonical_name_distribution.png')
    print("Saved distribution plot to canonical_name_distribution.png")
    
    # Evaluate a sample of canonical groups
    sample_size = min(20, len(canonical_groups))
    sample_groups = random.sample(list(canonical_groups.groups.keys()), sample_size)
    
    print("\nEvaluating sample canonical groups:")
    for i, canonical_name in enumerate(sample_groups, 1):
        group = canonical_groups.get_group(canonical_name)
        markets = group['market_name'].unique()
        
        print(f"\n{i}. Canonical Name: {canonical_name}")
        print(f"   Found in {len(markets)} markets: {', '.join(markets)}")
        print(f"   Number of products: {len(group)}")
        print("   Sample of original names:")
        for _, product in group.sample(min(3, len(group))).iterrows():
            print(f"   - {product['name']} ({product['market_name']}, {product['price']})")
    
    # Calculate market coverage
    market_coverage = defaultdict(set)
    for canonical_name, group in canonical_groups:
        markets = set(group['market_name'])
        market_coverage[len(markets)].add(canonical_name)
    
    print("\nMarket Coverage Statistics:")
    for num_markets, canonical_names in sorted(market_coverage.items()):
        print(f"Products found in {num_markets} markets: {len(canonical_names)}")
    
    # Close the connection
    cursor.close()
    conn.close()
    print("\nEvaluation complete")
    
except Exception as e:
    print(f"Database connection error: {e}")
    import traceback
    traceback.print_exc() 