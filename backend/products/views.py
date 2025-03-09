from django.db import connection
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
import logging
from django.db.models import Q
from users.models import Product
import re

logger = logging.getLogger(__name__)

@require_http_methods(['GET'])
def product_comparison(request, canonical_name):
    try:
        # Query the price_comparison view for this canonical name
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT * FROM price_comparison 
                WHERE canonical_name = %s
            """, [canonical_name])
            result = cursor.fetchone()
            
            if result:
                # Convert to dictionary
                columns = [col[0] for col in cursor.description]
                comparison_data = dict(zip(columns, result))
                
                # Ensure all required fields are present
                required_fields = [
                    'canonical_name', 'market_prices', 'min_price', 
                    'max_price', 'price_diff_percent', 'cheapest_market', 
                    'most_expensive_market', 'num_markets'
                ]
                
                for field in required_fields:
                    if field not in comparison_data:
                        logger.warning(f"Field {field} missing from price_comparison view")
                        if field == 'num_markets':
                            # Calculate number of markets from market_prices
                            if 'market_prices' in comparison_data:
                                market_count = len(comparison_data['market_prices'].split(', '))
                                comparison_data['num_markets'] = market_count
                            else:
                                comparison_data['num_markets'] = 0
                
                return JsonResponse(comparison_data)
            else:
                logger.info(f"No price comparison found for canonical_name: {canonical_name}")
                return JsonResponse({"error": "Product not found"}, status=404)
    except Exception as e:
        logger.error(f"Error in product_comparison view: {str(e)}")
        return JsonResponse({"error": str(e)}, status=500)

@require_http_methods(['GET'])
def search_similar_products(request, product_name):
    """
    Search for similar products across different markets based on product name.
    """
    try:
        # Clean up the product name for better matching
        search_term = product_name.lower().strip()
        
        # Get a list of all market product tables
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public' AND table_name LIKE '%_products'
            """)
            market_tables = [table[0] for table in cursor.fetchall()]
            
            if not market_tables:
                return JsonResponse({"error": "No market tables found"}, status=404)
            
            # Prepare search terms
            # Remove common units and numbers for better matching
            clean_search = re.sub(r'\d+\s*(ml|l|g|gr|kg|adet|lt|mm|cm|m)', '', search_term)
            clean_search = re.sub(r'\s+', ' ', clean_search).strip()
            
            # Get words from the search term
            search_words = clean_search.split()
            
            # Find products in each market table
            all_matching_products = []
            
            for table in market_tables:
                # Build a query to find products with similar names
                query = f"""
                    SELECT 
                        id, 
                        name, 
                        normalized_name, 
                        canonical_name,
                        price, 
                        image_url, 
                        market_name,
                        product_link
                    FROM {table}
                    WHERE price IS NOT NULL AND price > 0
                    AND (
                """
                
                # Add conditions for name matching
                conditions = []
                params = []
                
                # Exact match on normalized_name
                conditions.append("normalized_name = %s")
                params.append(search_term)
                
                # Partial match on normalized_name
                conditions.append("normalized_name ILIKE %s")
                params.append(f"%{search_term}%")
                
                # Match on name
                conditions.append("name ILIKE %s")
                params.append(f"%{search_term}%")
                
                # Match on individual words
                for word in search_words:
                    if len(word) > 2:  # Only use words with more than 2 characters
                        conditions.append("normalized_name ILIKE %s")
                        params.append(f"%{word}%")
                
                query += " OR ".join(conditions) + ")"
                query += " ORDER BY price ASC LIMIT 5"  # Get up to 5 matches per market
                
                cursor.execute(query, params)
                
                columns = [col[0] for col in cursor.description]
                for row in cursor.fetchall():
                    product = dict(zip(columns, row))
                    product['table'] = table
                    all_matching_products.append(product)
            
            if not all_matching_products:
                return JsonResponse({"error": "No similar products found"}, status=404)
            
            # Group products by market
            products_by_market = {}
            for product in all_matching_products:
                market = product['market_name']
                if market not in products_by_market:
                    products_by_market[market] = []
                products_by_market[market].append(product)
            
            # Get the cheapest product from each market
            cheapest_by_market = {}
            for market, products in products_by_market.items():
                cheapest = min(products, key=lambda p: float(p['price']) if p['price'] is not None else float('inf'))
                cheapest_by_market[market] = cheapest
            
            # Convert to list
            market_products = list(cheapest_by_market.values())
            
            # If we have products from multiple markets, create a comparison
            if len(market_products) > 1:
                # Calculate price range
                prices = [float(p['price']) for p in market_products if p['price'] is not None]
                min_price = min(prices) if prices else 0
                max_price = max(prices) if prices else 0
                
                # Calculate price difference percentage
                diff_percent = ((max_price - min_price) / min_price) * 100 if min_price > 0 else 0
                
                # Format market prices string
                market_prices_str = ', '.join([f"{p['market_name']}: {float(p['price'])}" for p in market_products])
                
                # Find cheapest and most expensive markets
                cheapest_market = min(market_products, key=lambda p: float(p['price']) if p['price'] is not None else float('inf'))['market_name']
                most_expensive_market = max(market_products, key=lambda p: float(p['price']) if p['price'] is not None else float('inf'))['market_name']
                
                # Create response data
                comparison_data = {
                    'canonical_name': product_name,  # Use the product name as canonical name
                    'market_prices': market_prices_str,
                    'min_price': min_price,
                    'max_price': max_price,
                    'price_diff': max_price - min_price,
                    'price_diff_percent': diff_percent,
                    'cheapest_market': cheapest_market,
                    'most_expensive_market': most_expensive_market,
                    'num_markets': len(market_products),
                    'detailed_market_prices': [
                        {
                            'market': p['market_name'],
                            'price': float(p['price']) if p['price'] is not None else 0,
                            'product_name': p['name'],
                            'product_link': p['product_link']
                        } for p in market_products
                    ]
                }
                
                return JsonResponse(comparison_data)
            else:
                return JsonResponse({"error": "Product not found in multiple markets"}, status=404)
                
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse({"error": str(e)}, status=500) 