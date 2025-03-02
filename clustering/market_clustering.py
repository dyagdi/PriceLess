import psycopg2
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import DBSCAN
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.neighbors import NearestNeighbors
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
    print(f"Found {len(tables)} tables in the database")
    
    # Filter tables to only include market product tables
    market_tables = [table for table in tables if table.endswith('_products')]
    print(f"Found {len(market_tables)} market product tables: {market_tables}")
    
    # Step 1: Fetch all normalized names from all market tables
    all_products = []
    
    for table in market_tables:
        try:
            # Check if the table has normalized_name column
            cursor.execute(f"""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = '{table}'
            """)
            columns = cursor.fetchall()
            column_names = [column['column_name'] for column in columns]
            
            if 'normalized_name' not in column_names:
                print(f"Table {table} does not have normalized_name column, skipping")
                continue
            
            # Extract market name from table name
            market_name = table.split('_')[0]
            
            # Fetch products with normalized names
            query = f"""
            SELECT 
                id, 
                name, 
                normalized_name, 
                price,
                '{market_name}' as market_name
            FROM {table} 
            WHERE normalized_name IS NOT NULL;
            """
            
            cursor.execute(query)
            products = cursor.fetchall()
            products_df = pd.DataFrame(products)
            print(f"Found {len(products_df)} products with normalized names in {table}")
            all_products.append(products_df)
        
        except Exception as e:
            print(f"Error processing table {table}: {e}")
    
    # Combine all products into a single DataFrame
    if all_products:
        products_df = pd.concat(all_products, ignore_index=True)
        print(f"Total products with normalized names: {len(products_df)}")
    else:
        print("No products found with normalized names")
        exit()
    
    # Step 2: Extract unique normalized names for clustering
    unique_names = products_df['normalized_name'].dropna().unique()
    print(f"Number of unique normalized names: {len(unique_names)}")
    
    # Display a sample of normalized names
    print("\nSample of normalized names:")
    for name in unique_names[:5]:
        print(name)
    
    # Step 3: Convert product names into TF-IDF vectors
    vectorizer = TfidfVectorizer()
    name_vectors = vectorizer.fit_transform(unique_names)
    print(f"Created TF-IDF vectors with shape: {name_vectors.shape}")
    
    # Step 4: Find optimal eps parameter for DBSCAN using k-distance graph
    k = 4  # Typically, use min_samples - 1
    neighbors = NearestNeighbors(n_neighbors=k)
    neighbors_fit = neighbors.fit(name_vectors)
    distances, _ = neighbors_fit.kneighbors(name_vectors)
    
    # Sort distances for k-th nearest neighbor
    distances = np.sort(distances[:, k-1], axis=0)
    
    # Plot the distances to find the elbow
    plt.figure(figsize=(10, 6))
    plt.plot(distances)
    plt.ylabel('k-distance')
    plt.xlabel('Points sorted by distance')
    plt.title('Elbow Method for Choosing eps')
    plt.savefig('k_distance_plot.png')
    print("Saved k-distance plot to k_distance_plot.png")
    
    # Step 5: Calculate cosine similarity and apply DBSCAN clustering
    distance_matrix = 1 - cosine_similarity(name_vectors)
    
    # Ensure non-negative distances
    distance_matrix[distance_matrix < 0] = 0
    
    # Apply DBSCAN clustering
    eps = 0.6  # You may need to adjust this based on the k-distance plot
    min_samples = 4  # Minimum number of samples in a cluster
    clustering_model = DBSCAN(eps=eps, min_samples=min_samples, metric='precomputed')
    clusters = clustering_model.fit_predict(distance_matrix)
    
    # Count the number of clusters (excluding noise points labeled as -1)
    n_clusters = len(set(clusters)) - (1 if -1 in clusters else 0)
    n_noise = list(clusters).count(-1)
    print(f"Number of clusters: {n_clusters}")
    print(f"Number of noise points: {n_noise}")
    
    # Step 6: Map clusters to canonical names
    name_clusters = pd.DataFrame({'name': unique_names, 'cluster': clusters})
    
    # Assign canonical names (e.g., the shortest name in each cluster)
    canonical_names = {}
    for cluster_id in set(clusters):
        if cluster_id != -1:  # Skip noise points
            cluster_names = name_clusters[name_clusters['cluster'] == cluster_id]['name']
            canonical_names[cluster_id] = min(cluster_names, key=len)  # Shortest name
    
    # Map names to their canonical form
    name_clusters['canonical_name'] = name_clusters['cluster'].map(
        lambda x: canonical_names.get(x) if x != -1 else None
    )
    
    # For noise points, use the original name as canonical name
    name_clusters.loc[name_clusters['cluster'] == -1, 'canonical_name'] = name_clusters.loc[name_clusters['cluster'] == -1, 'name']
    
    # Step 7: Create a mapping table for all normalized names to their canonical forms
    mapping_dict = dict(zip(name_clusters['name'], name_clusters['canonical_name']))
    
    # Step 8: Update all product tables with canonical names
    for table in market_tables:
        try:
            # Check if the table has normalized_name column
            cursor.execute(f"""
                SELECT column_name 
                FROM information_schema.columns 
                WHERE table_name = '{table}'
            """)
            columns = cursor.fetchall()
            column_names = [column['column_name'] for column in columns]
            
            if 'normalized_name' not in column_names:
                continue
            
            # Add canonical_name column if it doesn't exist
            if 'canonical_name' not in column_names:
                cursor.execute(f"ALTER TABLE {table} ADD COLUMN canonical_name TEXT;")
                conn.commit()
                print(f"Added canonical_name column to {table}")
            
            # Fetch all normalized names from the table
            cursor.execute(f"SELECT id, normalized_name FROM {table} WHERE normalized_name IS NOT NULL;")
            rows = cursor.fetchall()
            
            # Update canonical names
            update_count = 0
            for row in rows:
                id = row['id']
                norm_name = row['normalized_name']
                canonical_name = mapping_dict.get(norm_name)
                
                if canonical_name:
                    cursor.execute(f"UPDATE {table} SET canonical_name = %s WHERE id = %s;", 
                                  (canonical_name, id))
                    update_count += 1
                    
                    # Commit every 1000 updates to avoid transaction bloat
                    if update_count % 1000 == 0:
                        conn.commit()
                        print(f"Committed {update_count} updates so far in {table}")
            
            conn.commit()
            print(f"Updated {update_count} products with canonical names in {table}")
            
        except Exception as e:
            print(f"Error updating canonical names in {table}: {e}")
    
    # Step 9: Create a view for price comparison
    try:
        # First, check if the view already exists and drop it
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.views 
            WHERE table_schema = 'public' AND table_name = 'price_comparison'
        """)
        if cursor.fetchone():
            cursor.execute("DROP VIEW price_comparison;")
            conn.commit()
            print("Dropped existing price_comparison view")
        
        # Create the price comparison view with a corrected query
        price_comparison_query = """
        CREATE VIEW price_comparison AS
        WITH product_prices AS (
        """
        
        # Add UNION ALL queries for each market table
        for i, table in enumerate(market_tables):
            market_name = table.split('_')[0]
            if i == 0:
                price_comparison_query += f"""
                SELECT
                    canonical_name,
                    '{market_name}' as market_name,
                    price
                FROM {table}
                WHERE canonical_name IS NOT NULL
                """
            else:
                price_comparison_query += f"""
                UNION ALL
                SELECT
                    canonical_name,
                    '{market_name}' as market_name,
                    price
                FROM {table}
                WHERE canonical_name IS NOT NULL
                """
        
        price_comparison_query += """
        ),
        min_prices AS (
            SELECT 
                canonical_name,
                market_name,
                MIN(price) as min_price
            FROM product_prices
            GROUP BY canonical_name, market_name
        ),
        market_rankings AS (
            SELECT
                canonical_name,
                market_name,
                min_price,
                ROW_NUMBER() OVER (PARTITION BY canonical_name ORDER BY min_price ASC) as cheapest_rank,
                ROW_NUMBER() OVER (PARTITION BY canonical_name ORDER BY min_price DESC) as expensive_rank
            FROM min_prices
        )
        SELECT 
            m.canonical_name,
            string_agg(m.market_name || ': ' || m.min_price::text, ', ') as market_prices,
            MIN(m.min_price) as min_price,
            MAX(m.min_price) as max_price,
            (MAX(m.min_price) - MIN(m.min_price)) as price_diff,
            CASE 
                WHEN MIN(m.min_price) > 0 THEN ((MAX(m.min_price) - MIN(m.min_price)) / MIN(m.min_price)) * 100 
                ELSE 0 
            END as price_diff_percent,
            (SELECT market_name FROM market_rankings 
             WHERE canonical_name = m.canonical_name AND cheapest_rank = 1 LIMIT 1) as cheapest_market,
            (SELECT market_name FROM market_rankings 
             WHERE canonical_name = m.canonical_name AND expensive_rank = 1 LIMIT 1) as most_expensive_market,
            COUNT(DISTINCT m.market_name) as num_markets
        FROM min_prices m
        GROUP BY m.canonical_name
        HAVING COUNT(DISTINCT m.market_name) > 1
        ORDER BY price_diff_percent DESC;
        """
        
        cursor.execute(price_comparison_query)
        conn.commit()
        print("Created price_comparison view")
        
        # Export price comparison data to CSV
        cursor.execute("SELECT * FROM price_comparison")
        price_comparison_data = cursor.fetchall()
        price_comparison_df = pd.DataFrame(price_comparison_data)
        
        if len(price_comparison_df) > 0:
            price_comparison_df.to_csv("price_comparison.csv", index=False)
            print(f"Exported {len(price_comparison_df)} price comparisons to price_comparison.csv")
            
            # Display a sample of the price comparison results
            print("\nSample price comparisons:")
            pd.set_option('display.max_columns', None)
            pd.set_option('display.width', 1000)
            print(price_comparison_df.head(10))
        else:
            print("No price comparisons found. Make sure products have canonical names and exist in multiple markets.")
        
    except Exception as e:
        print(f"Error creating price_comparison view: {e}")
        import traceback
        traceback.print_exc()
    
    # Close the connection
    cursor.close()
    conn.close()
    print("Clustering and price comparison complete")
    
except Exception as e:
    print(f"Database connection error: {e}")
    import traceback
    traceback.print_exc() 