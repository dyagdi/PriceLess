import psycopg2
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
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
    
    # Step 1: Check if price_comparison view exists
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.views 
        WHERE table_schema = 'public' AND table_name = 'price_comparison'
    """)
    if not cursor.fetchone():
        print("Price comparison view not found. Please run market_clustering.py first.")
        exit()
    
    # Step 2: Fetch price comparison data
    cursor.execute("SELECT * FROM price_comparison")
    price_comparison_data = cursor.fetchall()
    price_comparison = pd.DataFrame(price_comparison_data)
    print(f"Found {len(price_comparison)} products with price comparisons")
    
    # Step 3: Analyze which market is generally cheapest
    market_stats = pd.DataFrame()
    
    # Get list of unique markets
    cursor.execute("""
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' AND table_name LIKE '%_products'
    """)
    market_tables = cursor.fetchall()
    markets = [table['table_name'].split('_')[0] for table in market_tables]
    market_stats['market'] = markets
    
    # Count how often each market is the cheapest or most expensive
    market_stats['times_cheapest'] = market_stats['market'].apply(
        lambda market: sum(price_comparison['cheapest_market'] == market)
    )
    
    market_stats['times_most_expensive'] = market_stats['market'].apply(
        lambda market: sum(price_comparison['most_expensive_market'] == market)
    )
    
    # Calculate percentage of times each market is cheapest
    total_comparisons = len(price_comparison)
    market_stats['percent_cheapest'] = (market_stats['times_cheapest'] / total_comparisons) * 100
    
    # Sort by times cheapest (descending)
    market_stats = market_stats.sort_values('times_cheapest', ascending=False)
    
    print("\nMarket comparison (which market is generally cheapest):")
    print(market_stats)
    
    # Step 4: Visualize market comparison
    plt.figure(figsize=(12, 6))
    market_stats_melted = pd.melt(
        market_stats, 
        id_vars=['market'], 
        value_vars=['times_cheapest', 'times_most_expensive'],
        var_name='metric', 
        value_name='count'
    )
    sns.barplot(x='market', y='count', hue='metric', data=market_stats_melted)
    plt.title('Market Comparison: Number of Times Cheapest vs. Most Expensive')
    plt.xlabel('Market')
    plt.ylabel('Count')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('market_comparison.png')
    
    # Step 5: Visualize price difference distribution
    plt.figure(figsize=(12, 6))
    sns.histplot(pd.to_numeric(price_comparison['price_diff_percent']).clip(0, 200), bins=50)
    plt.title('Distribution of Price Differences (%)')
    plt.xlabel('Price Difference (%)')
    plt.ylabel('Count')
    plt.savefig('price_difference_distribution.png')
    
    # Step 6: Find products with the largest price differences
    largest_diff = price_comparison.sort_values('price_diff_percent', ascending=False).head(20)
    print("\nProducts with the largest price differences:")
    print(largest_diff[['canonical_name', 'min_price', 'max_price', 'price_diff_percent', 'cheapest_market', 'most_expensive_market']])
    
    # Step 7: Save analysis results to CSV
    market_stats.to_csv("market_stats.csv", index=False)
    largest_diff.to_csv("largest_price_differences.csv", index=False)
    
    print("\nAnalysis complete. Results saved to CSV files and visualizations saved as PNG files.")
    
    # Close the connection
    cursor.close()
    conn.close()
    
except Exception as e:
    print(f"Database connection error: {e}")
    import traceback
    traceback.print_exc() 