from django.contrib.auth.models import User  # Import User model
from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.response import Response
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate, login
from django.views.decorators.csrf import csrf_exempt
import json
from .models import Product  # Product modelini içe aktarın
from .serializers import UserSerializer, ProductSerializer  # Serializer'ları içe aktarın
from django.db.models import F
from django.db import connection


# Test View
def test_view(request):
    """API'nin çalışıp çalışmadığını test etmek için bir view"""
    return HttpResponse("Server is up and running!")

# Kullanıcı Kaydı
class UserRegistrationView(generics.CreateAPIView):
    """Kullanıcı kayıt işlemi"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

# Kullanıcı Girişi
@csrf_exempt
def user_login(request):
    """Kullanıcı girişi için view"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            email = data.get('email')
            password = data.get('password')

            user = authenticate(request, username=email, password=password)
            if user is not None:
                login(request, user)
                return JsonResponse({'message': 'Login successful!'}, status=200)
            else:
                return JsonResponse({'error': 'Invalid email or password.'}, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)

    return JsonResponse({'error': 'POST request required.'}, status=405)

# Ürün Listesi API'si
class ProductListAPIView(APIView):
    """Tüm ürünleri dönen bir API"""
    def get(self, request):
        try:
            products = Product.objects.all()
            serializer = ProductSerializer(products, many=True)
            return Response(serializer.data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=500)

# Özel Kategori veya Filtrelenmiş Ürün API'si (Opsiyonel)
class HomePageProductListAPIView(APIView):
    """Filtrelenmiş ürünleri dönen bir API"""
    def get(self, request):
        category = request.query_params.get('category', None)
        in_stock = request.query_params.get('in_stock', None)

        try:
            products = Product.objects.all()

            if category:
                products = products.filter(main_category__icontains=category)

            if in_stock is not None:
                products = products.filter(in_stock=in_stock.lower() == 'true')

            serializer = ProductSerializer(products, many=True)
            return Response(serializer.data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=500)

# En Ucuz 4 Ürünü Dönen API
def cheapest_products(request):
    """En ucuz 4 ürünü döner."""
    try:
        products = Product.objects.order_by('price')[:8]  # Fiyata göre sırala, ilk 4 ürünü al
        data = [{"name": p.name, "price": p.price, "image": p.image_url} for p in products]
        return JsonResponse(data, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def cheapest_products_per_category(request):
    """Her kategoriden en ucuz 4 ürünü döner."""
    try:
        categories = Product.objects.values_list('main_category', flat=True).distinct()  # Benzersiz kategorileri al
        data = []

        for category in categories:
            cheapest_products = (
                Product.objects.filter(main_category=category)
                .order_by('price')[:4]
            )
            data.extend([
                {
                    "id": str(p.id),
                    "name": p.name,
                    "normalized_name": p.normalized_name if hasattr(p, 'normalized_name') else None,
                    "canonical_name": p.canonical_name if hasattr(p, 'canonical_name') else None,
                    "price": p.price,
                    "image": p.image_url,
                    "category": p.main_category,
                    "market_name": p.market_name
                }
                for p in cheapest_products
            ])

        return JsonResponse(data, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def products_in_multiple_markets(request):
    """Fetch products that are available in multiple markets."""
    try:
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
            
            # Get products with canonical names that appear in multiple markets
            canonical_names_query = """
                WITH canonical_counts AS (
                    SELECT canonical_name, COUNT(DISTINCT table_name) as market_count
                    FROM (
            """
            
            for i, table in enumerate(market_tables):
                if i > 0:
                    canonical_names_query += " UNION ALL "
                canonical_names_query += f"""
                    SELECT canonical_name, '{table}' as table_name
                    FROM {table}
                    WHERE canonical_name IS NOT NULL AND canonical_name != ''
                """
            
            canonical_names_query += """
                    ) AS all_products
                    GROUP BY canonical_name
                    HAVING COUNT(DISTINCT table_name) > 1 AND canonical_name != ''
                )
                SELECT canonical_name, market_count
                FROM canonical_counts
                ORDER BY market_count DESC
                LIMIT 30;
            """
            
            cursor.execute(canonical_names_query)
            results = cursor.fetchall()
            
            if not results:
                return JsonResponse({"error": "No products found in multiple markets"}, status=404)
            
            # For each canonical name, get one product from each market
            products_data = []
            for canonical_name, _ in results:
                # Products from different markets with this canonical name
                market_products = []
                
                for table in market_tables:
                    cursor.execute(f"""
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
                        WHERE canonical_name = %s AND price IS NOT NULL
                        ORDER BY price ASC
                        LIMIT 1
                    """, [canonical_name])
                    
                    products = cursor.fetchall()
                    if products:
                        # Get column names
                        columns = [col[0] for col in cursor.description]
                        
                        # Convert to dictionary
                        for product in products:
                            product_dict = dict(zip(columns, product))
                            
                            # Ensure price is a valid number
                            price = product_dict.get("price")
                            if price is not None:
                                try:
                                    price = float(price)
                                except (ValueError, TypeError):
                                    # Skip products with invalid prices
                                    continue
                                
                                market_products.append({
                                    "id": str(product_dict["id"]),
                                    "name": product_dict["name"] or "",
                                    "normalized_name": product_dict["normalized_name"] or "",
                                    "canonical_name": product_dict["canonical_name"] or "",
                                    "price": price,
                                    "image": product_dict["image_url"] or "",
                                    "market_name": product_dict["market_name"] or "",
                                    "product_link": product_dict["product_link"] or ""
                                })
                
                # Add to products data if we found products in multiple markets
                if len(market_products) > 1:
                    # Get the product with the lowest price as the representative
                    representative = min(market_products, key=lambda x: x["price"])
                    representative["available_markets"] = len(market_products)
                    
                    # Calculate price range
                    min_price = min(p["price"] for p in market_products)
                    max_price = max(p["price"] for p in market_products)
                    
                    # Calculate price difference percentage
                    if min_price > 0:
                        diff_percent = ((max_price - min_price) / min_price) * 100
                    else:
                        diff_percent = 0
                    
                    representative["price_range"] = {
                        "min": min_price,
                        "max": max_price,
                        "diff_percent": diff_percent
                    }
                    products_data.append(representative)
            
            return JsonResponse(products_data, safe=False)
            
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse({"error": str(e)}, status=500)

def similar_products_across_markets(request):
    """Find similar products across markets using normalized names."""
    try:
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
            
            # Get all products with normalized names
            all_products = []
            for table in market_tables:
                cursor.execute(f"""
                    SELECT 
                        id, 
                        name, 
                        normalized_name, 
                        price, 
                        image_url, 
                        market_name,
                        product_link
                    FROM {table}
                    WHERE normalized_name IS NOT NULL 
                    AND normalized_name != '' 
                    AND price IS NOT NULL
                    AND price > 0
                """)
                
                columns = [col[0] for col in cursor.description]
                for row in cursor.fetchall():
                    product = dict(zip(columns, row))
                    product['table'] = table
                    all_products.append(product)
            
            # Group products by normalized name
            products_by_normalized_name = {}
            for product in all_products:
                normalized_name = product['normalized_name']
                if normalized_name not in products_by_normalized_name:
                    products_by_normalized_name[normalized_name] = []
                products_by_normalized_name[normalized_name].append(product)
            
            # Filter to keep only normalized names that appear in multiple markets
            multi_market_products = {}
            for normalized_name, products in products_by_normalized_name.items():
                # Get unique markets
                markets = set(p['market_name'] for p in products)
                if len(markets) > 1:
                    multi_market_products[normalized_name] = products
            
            # Sort by number of markets (descending)
            sorted_products = sorted(
                multi_market_products.items(), 
                key=lambda x: len(set(p['market_name'] for p in x[1])),
                reverse=True
            )
            
            # Prepare response data
            result_data = []
            for normalized_name, products in sorted_products[:30]:  # Limit to 30 products
                # Group by market and find cheapest in each market
                cheapest_by_market = {}
                for product in products:
                    market = product['market_name']
                    if market not in cheapest_by_market or product['price'] < cheapest_by_market[market]['price']:
                        cheapest_by_market[market] = product
                
                # Convert to list of products
                market_products = list(cheapest_by_market.values())
                
                # Skip if we don't have at least 2 markets
                if len(market_products) < 2:
                    continue
                
                # Get the product with the lowest price as the representative
                try:
                    representative = min(market_products, key=lambda x: float(x['price']))
                    
                    # Calculate price range
                    prices = [float(p['price']) for p in market_products]
                    min_price = min(prices)
                    max_price = max(prices)
                    
                    # Calculate price difference percentage
                    diff_percent = ((max_price - min_price) / min_price) * 100 if min_price > 0 else 0
                    
                    # Format the response
                    result_data.append({
                        "id": str(representative['id']),
                        "name": representative['name'] or "",
                        "normalized_name": normalized_name,
                        "price": float(representative['price']),
                        "image": representative['image_url'] or "",
                        "market_name": representative['market_name'] or "",
                        "product_link": representative['product_link'] or "",
                        "available_markets": len(market_products),
                        "price_range": {
                            "min": min_price,
                            "max": max_price,
                            "diff_percent": diff_percent
                        }
                    })
                except (ValueError, TypeError) as e:
                    # Skip products with invalid prices
                    print(f"Error processing product: {e}")
                    continue
            
            # Sort by price difference percentage (descending)
            result_data.sort(key=lambda x: x['price_range']['diff_percent'], reverse=True)
            
            return JsonResponse(result_data, safe=False)
            
    except Exception as e:
        import traceback
        traceback.print_exc()
        return JsonResponse({"error": str(e)}, status=500)        