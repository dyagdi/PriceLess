from django.contrib.auth.models import User  
from django.db import connection
from rest_framework import generics
from rest_framework.permissions import AllowAny
from rest_framework.views import APIView
from rest_framework.response import Response
from django.http import HttpResponse, JsonResponse
from django.contrib.auth import authenticate, login
from django.views.decorators.csrf import csrf_exempt
import json
from .models import FavoriteCartProduct, Product, MopasProduct, MigrosProduct, SokmarketProduct, MarketpaketiProduct, CarrefourProduct 
from .serializers import UserSerializer, ProductSerializer, MopasProductSerializer, MigrosProductSerializer, SokmarketProductSerializer, MarketpaketiProductSerializer, CarrefourProductSerializer
# Commenting out search vector imports as they're not currently being used
# from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector
from .models import FavoriteCart
from .serializers import FavoriteCartSerializer
from rest_framework import permissions
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view
from itertools import chain
from django.db.models import F






def test_view(request):
    """API'nin çalışıp çalışmadığını test etmek için bir view"""
    return HttpResponse("Server is up and running!")


class UserRegistrationView(generics.CreateAPIView):
    """Kullanıcı kayıt işlemi"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Create token for the new user
        token, created = Token.objects.get_or_create(user=user)
        
        return Response({
            'token': token.key,
            'user_id': user.id,
            'username': user.username
        }, status=status.HTTP_201_CREATED)


@api_view(['POST'])
def user_login(request):
    """Kullanıcı girişi için view"""
    email = request.data.get('email')
    password = request.data.get('password')
    
    print(f"Received login attempt - email: {email}")  # Debug print
    
    # Try authenticating with email as username
    user = authenticate(username=email, password=password)
    
    if user:
        token, created = Token.objects.get_or_create(user=user)
        return Response({
            'token': token.key,
            'user_id': user.id,
            'username': user.username
        })
    
    return Response({'error': 'Invalid credentials'}, status=400)



class ProductListAPIView(APIView):
    """Tüm ürünleri dönen bir API"""
    def get(self, request):
        try:
            # Get products from all market tables
            mopas_products = MopasProduct.objects.all()
            migros_products = MigrosProduct.objects.all()
            sokmarket_products = SokmarketProduct.objects.all()
            marketpaketi_products = MarketpaketiProduct.objects.all()
            carrefour_products = CarrefourProduct.objects.all()
            
            # Combine products from different markets
            combined_data = []
            
            combined_data.extend(MopasProductSerializer(mopas_products, many=True).data)
            combined_data.extend(MigrosProductSerializer(migros_products, many=True).data)
            combined_data.extend(SokmarketProductSerializer(sokmarket_products, many=True).data)
            combined_data.extend(MarketpaketiProductSerializer(marketpaketi_products, many=True).data)
            combined_data.extend(CarrefourProductSerializer(carrefour_products, many=True).data)
            
            return Response(combined_data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=500)


class HomePageProductListAPIView(APIView):
    """Filtrelenmiş ürünleri dönen bir API"""
    def get(self, request):
        category = request.query_params.get('category', None)
        in_stock = request.query_params.get('in_stock', None)

        try:
            # Get filtered products from all market tables
            mopas_products = MopasProduct.objects.all()
            migros_products = MigrosProduct.objects.all()
            sokmarket_products = SokmarketProduct.objects.all()
            marketpaketi_products = MarketpaketiProduct.objects.all()
            carrefour_products = CarrefourProduct.objects.all()
            
            # Apply filters to each market's products
            if category:
                mopas_products = mopas_products.filter(main_category__icontains=category)
                migros_products = migros_products.filter(main_category__icontains=category)
                sokmarket_products = sokmarket_products.filter(main_category__icontains=category)
                marketpaketi_products = marketpaketi_products.filter(main_category__icontains=category)
                carrefour_products = carrefour_products.filter(main_category__icontains=category)

            if in_stock is not None:
                in_stock_value = in_stock.lower() == 'true'
                mopas_products = mopas_products.filter(in_stock=in_stock_value)
                migros_products = migros_products.filter(in_stock=in_stock_value)
                sokmarket_products = sokmarket_products.filter(in_stock=in_stock_value)
                marketpaketi_products = marketpaketi_products.filter(in_stock=in_stock_value)
                carrefour_products = carrefour_products.filter(in_stock=in_stock_value)
            
            # Combine products from different markets
            combined_data = []
            
            combined_data.extend(MopasProductSerializer(mopas_products, many=True).data)
            combined_data.extend(MigrosProductSerializer(migros_products, many=True).data)
            combined_data.extend(SokmarketProductSerializer(sokmarket_products, many=True).data)
            combined_data.extend(MarketpaketiProductSerializer(marketpaketi_products, many=True).data)
            combined_data.extend(CarrefourProductSerializer(carrefour_products, many=True).data)
            
            return Response(combined_data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=500)


def cheapest_products(request):
    """Her marketten en ucuz 4 ürünü döner."""
    try:
        # Products organized by market
        market_products = {
            "Mopas": [],
            "Migros": [],
            "Şok Market": [],
            "Market Paketi": [],
            "Carrefour": []
        }
        
        # Try to get products from each model, but continue if one fails
        try:
            for product in MopasProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Mopas"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "market_name": "Mopas"  # Add market name
                        })
                except Exception as e:
                    print(f"Error processing MopasProduct: {e}")
        except Exception as e:
            print(f"Error querying MopasProduct: {e}")
        
        try:
            for product in MigrosProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Migros"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "market_name": "Migros"  # Add market name
                        })
                except Exception as e:
                    print(f"Error processing MigrosProduct: {e}")
        except Exception as e:
            print(f"Error querying MigrosProduct: {e}")
        
        try:
            for product in SokmarketProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Şok Market"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "market_name": "Şok Market"  # Add market name
                        })
                except Exception as e:
                    print(f"Error processing SokmarketProduct: {e}")
        except Exception as e:
            print(f"Error querying SokmarketProduct: {e}")
        
        try:
            for product in MarketpaketiProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Market Paketi"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "market_name": "Market Paketi"  # Add market name
                        })
                except Exception as e:
                    print(f"Error processing MarketpaketiProduct: {e}")
        except Exception as e:
            print(f"Error querying MarketpaketiProduct: {e}")
        
        try:
            for product in CarrefourProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Carrefour"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "market_name": "Carrefour"  # Add market name
                        })
                except Exception as e:
                    print(f"Error processing CarrefourProduct: {e}")
        except Exception as e:
            print(f"Error querying CarrefourProduct: {e}")
        
        # Results to return
        cheapest_products = []
        
        # For each market, sort products by price and take the 4 cheapest
        for market, products in market_products.items():
            # Skip markets with no products
            if not products:
                continue
                
            # Sort by price
            products.sort(key=lambda x: x["price"])
            
            # Take the 4 cheapest products from this market
            cheapest_in_market = products[:4] if len(products) > 4 else products
            
            # Add to results
            cheapest_products.extend(cheapest_in_market)
        
        return JsonResponse(cheapest_products, safe=False)
    except Exception as e:
        import traceback
        print(f"Error in cheapest_products: {e}")
        print(traceback.format_exc())
        # Return an empty list instead of an error to prevent the frontend from breaking
        return JsonResponse([], safe=False)

def cheapest_products_per_category(request):
    """Her marketten en ucuz 4 ürünü döner."""
    try:
        # Products organized by market
        market_products = {
            "Mopas": [],
            "Migros": [],
            "Şok Market": [],
            "Market Paketi": [],
            "Carrefour": []
        }
        
        # Get all products from each market
        try:
            for product in MopasProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Mopas"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": product.main_category,
                            "market_name": "Mopas"
                        })
                except Exception as e:
                    print(f"Error processing MopasProduct: {e}")
        except Exception as e:
            print(f"Error querying MopasProduct: {e}")
        
        try:
            for product in MigrosProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Migros"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": product.main_category,
                            "market_name": "Migros"
                        })
                except Exception as e:
                    print(f"Error processing MigrosProduct: {e}")
        except Exception as e:
            print(f"Error querying MigrosProduct: {e}")
        
        try:
            for product in SokmarketProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Şok Market"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": product.main_category,
                            "market_name": "Şok Market"
                        })
                except Exception as e:
                    print(f"Error processing SokmarketProduct: {e}")
        except Exception as e:
            print(f"Error querying SokmarketProduct: {e}")
        
        try:
            for product in MarketpaketiProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Market Paketi"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": product.main_category,
                            "market_name": "Market Paketi"
                        })
                except Exception as e:
                    print(f"Error processing MarketpaketiProduct: {e}")
        except Exception as e:
            print(f"Error querying MarketpaketiProduct: {e}")
        
        try:
            for product in CarrefourProduct.objects.all():
                try:
                    # Only include products with valid price
                    if product.price is not None:
                        market_products["Carrefour"].append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": product.main_category,
                            "market_name": "Carrefour"
                        })
                except Exception as e:
                    print(f"Error processing CarrefourProduct: {e}")
        except Exception as e:
            print(f"Error querying CarrefourProduct: {e}")
        
        # Final results to return - exactly 4 cheapest products from each market
        results = []
        
        # For each market, sort by price and take the 4 cheapest
        for market, products in market_products.items():
            # Skip markets with no products
            if not products:
                continue
                
            # Sort by price
            products.sort(key=lambda x: x["price"])
            
            # Take exactly 4 cheapest products (or all if less than 4)
            cheapest_in_market = products[:4] if len(products) > 4 else products
            
            # Add to results
            results.extend(cheapest_in_market)
        
        return JsonResponse(results, safe=False)
    except Exception as e:
        import traceback
        print(f"Error in cheapest_products_per_category: {e}")
        print(traceback.format_exc())
        # Return an empty list instead of an error to prevent the frontend from breaking
        return JsonResponse([], safe=False)
    
def search_products(request):
    """Ürün aramak için kullanılan endpoint"""
    query = request.GET.get('q', '')
    
    if query:
        # Initialize empty list for results
        results = []
        
        # Search in each market table using simple name__icontains filter
        # avoiding any search_vector functionality
        for table_name, model, market_name in [
            ('mopas_products', MopasProduct, "Mopas"),
            ('migros_products', MigrosProduct, "Migros"),
            ('sokmarket_products', SokmarketProduct, "Şok Market"),
            ('marketpaketi_products', MarketpaketiProduct, "Market Paketi"),
            ('carrefour_products', CarrefourProduct, "Carrefour")
        ]:
            try:
                # Use basic filtering with name__icontains
                matching_products = model.objects.filter(name__icontains=query)
                
                for product in matching_products:
                    try:
                        results.append({
                            'id': product.id,
                            'name': product.name,
                            'price': product.price,
                            'high_price': product.high_price,
                            'in_stock': product.in_stock,
                            'image_url': product.image_url,
                            'market_name': market_name,
                            'product_link': product.product_link,
                        })
                    except Exception as e:
                        print(f"Error processing search result from {table_name}: {e}")
            except Exception as e:
                print(f"Error searching in {table_name}: {e}")

        if results:
            return JsonResponse(results, safe=False)
        else:
            return JsonResponse({'error': 'No results found'}, status=404)
    else:
        return JsonResponse({'error': 'No search query provided'}, status=400)
    


class FavoriteCartListCreateView(generics.ListCreateAPIView):
    serializer_class = FavoriteCartSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return FavoriteCart.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        user = self.request.user
        # Create a new FavoriteCart for the user
        favorite_cart = FavoriteCart.objects.create(user=user)

        # Get the shopping cart data from request (Assuming it's sent in JSON format)
        cart_data = self.request.data.get('products', [])
        
        # Add products to the FavoriteCartProduct table
        for product in cart_data:
            FavoriteCartProduct.objects.create(
                favorite_cart=favorite_cart,
                user=user,
                name=product['name'],
                price=product['price'],
                image=product['image'],
                quantity=product['quantity']
            )

        return Response({"message": "Cart saved successfully!"}, status=status.HTTP_201_CREATED)

class MarketsListAPIView(APIView):
    def get(self, request):
        try:
            markets_data = {
                "Mopas": [],
                "Migros": [],
                "Şok Market": [],
                "Market Paketi": [],
                "Carrefour": []
            }
            
            # Get products from each market
            mopas_products = MopasProduct.objects.all()
            for product in mopas_products:
                markets_data["Mopas"].append({
                    "name": product.name,
                    "price": product.price,
                    "image": product.image_url,
                    "category": product.main_category
                })
                
            migros_products = MigrosProduct.objects.all()
            for product in migros_products:
                markets_data["Migros"].append({
                    "name": product.name,
                    "price": product.price,
                    "image": product.image_url,
                    "category": product.main_category
                })
                
            sokmarket_products = SokmarketProduct.objects.all()
            for product in sokmarket_products:
                markets_data["Şok Market"].append({
                    "name": product.name,
                    "price": product.price,
                    "image": product.image_url,
                    "category": product.main_category
                })
                
            marketpaketi_products = MarketpaketiProduct.objects.all()
            for product in marketpaketi_products:
                markets_data["Market Paketi"].append({
                    "name": product.name,
                    "price": product.price,
                    "image": product.image_url,
                    "category": product.main_category
                })
                
            carrefour_products = CarrefourProduct.objects.all()
            for product in carrefour_products:
                markets_data["Carrefour"].append({
                    "name": product.name,
                    "price": product.price,
                    "image": product.image_url,
                    "category": product.main_category
                })

            response_data = [
                {
                    "marketName": market,
                    "products": market_products,
                }
                for market, market_products in markets_data.items()
                if market_products  # Only include markets with products
            ]

            return JsonResponse(response_data, safe=False)
        except Exception as e:
            print(f"Error in MarketsListAPIView: {e}")
            return JsonResponse({'error': str(e)}, status=500)
        
from django.http import JsonResponse
from django.db.models import F
from rest_framework.views import APIView

class DiscountedProductsAPIView(APIView):
    """İndirimde olan ürünleri dönen bir API"""
    def get(self, request):
        try:
            # Define normalized category names (reusing from cheapest_products_by_categories)
            normalized_categories = {
                "fruits_vegetables": "Meyve ve Sebze",  # All fruit & vegetable variations
                "beverages": "İçecekler",  # All beverage variations
                "meat_poultry_fish": "Et, Tavuk ve Balık",  # All meat variations
                "basic_food": "Temel Gıda",  # All basic food variations
                "frozen_food": "Dondurulmuş Gıda"  # All frozen food variations
            }
            
            # Define mapping from market-specific categories to normalized categories
            category_mapping = {
                # Migros categories
                "Meyve, Sebze": "fruits_vegetables",
                "İçecek": "beverages",
                "Et, Tavuk, Balık": "meat_poultry_fish",
                "Temel Gıda": "basic_food",
                "Dondurulmuş Gıda": "frozen_food",
                
                # Şok Market categories
                "Meyve & Sebze": "fruits_vegetables",
                "İçecek": "beverages",
                "Et & Tavuk & Şarküteri": "meat_poultry_fish",
                "Yemeklik Malzemeler": "basic_food",
                "Dondurulmuş Ürünler": "frozen_food",
                
                # Mopas categories
                "Sebze & Meyve": "fruits_vegetables",
                "İçecekler": "beverages",
                "Kırmızı/Beyaz Et": "meat_poultry_fish",
                "Gıda & Şekerleme": "basic_food",
                
                # Market Paketi categories (all GIDA for now)
                "GIDA": "basic_food",
                
                # Carrefour categories
                "Meyve, Sebze": "fruits_vegetables",
                "İçecekler": "beverages",
                "Et, Tavuk, Balık": "meat_poultry_fish",
                "Temel Gıda": "basic_food",
                "Hazır Yemek&Donuk Ürünler": "frozen_food"
            }
            
            # Define market-specific categories
            market_categories = {
                "Migros": [
                    "Meyve, Sebze",
                    "İçecek",
                    "Et, Tavuk, Balık",
                    "Temel Gıda",
                    "Dondurulmuş Gıda"
                ],
                "Şok Market": [
                    "Meyve & Sebze",
                    "İçecek",
                    "Et & Tavuk & Şarküteri",
                    "Yemeklik Malzemeler",
                    "Dondurulmuş Ürünler"
                ],
                "Mopas": [
                    "Sebze & Meyve",
                    "İçecekler",
                    "Kırmızı/Beyaz Et",
                    "Gıda & Şekerleme"
                ],
                "Market Paketi": [
                    "GIDA"
                ],
                "Carrefour": [
                    "Meyve, Sebze",
                    "İçecekler",
                    "Et, Tavuk, Balık",
                    "Temel Gıda",
                    "Hazır Yemek&Donuk Ürünler"
                ]
            }
            
            # Final list of discounted products
            all_discounted_products = []
            
            # Maximum number of discounted products to show per market per category
            max_products_per_market_category = 4
            
            # Process each market
            markets = ["Mopas", "Migros", "Şok Market", "Market Paketi", "Carrefour"]
            market_model_mapping = {
                "Mopas": (MopasProduct, MopasProductSerializer),
                "Migros": (MigrosProduct, MigrosProductSerializer),
                "Şok Market": (SokmarketProduct, SokmarketProductSerializer),
                "Market Paketi": (MarketpaketiProduct, MarketpaketiProductSerializer),
                "Carrefour": (CarrefourProduct, CarrefourProductSerializer)
            }
            
            for market_name in markets:
                try:
                    model_class, serializer_class = market_model_mapping[market_name]
                    
                    # Get all discounted products from this market
                    market_discounted = model_class.objects.filter(
                        high_price__isnull=False,
                        price__lt=F('high_price')
                    ).order_by('price')
                    
                    # Process each product
                    for product in market_discounted:
                        # Skip products with no price
                        if product.price is None:
                            continue
                            
                        # Get normalized category if available
                        category = product.main_category
                        normalized_category = None
                        if category in category_mapping:
                            normalized_key = category_mapping[category]
                            normalized_category = normalized_categories[normalized_key]
                        
                        # Calculate discount percentage
                        discount_percentage = round(((product.high_price - product.price) / product.high_price) * 100) if product.high_price else 0
                        
                        # Format the product data
                        product_data = serializer_class(product).data
                        
                        # Add additional fields needed by frontend
                        product_data['market_name'] = market_name
                        product_data['discount_percentage'] = discount_percentage
                        product_data['image'] = product_data.get('image_url')  # Ensure image field exists
                        
                        # For category display in frontend
                        if normalized_category:
                            product_data['category'] = normalized_category
                        else:
                            product_data['category'] = category if category else "Genel"
                            
                        # Add to results
                        all_discounted_products.append(product_data)
                except Exception as e:
                    print(f"Error processing {market_name} discounted products: {e}")
            
            # Sort all products by discount percentage (highest first)
            all_discounted_products.sort(key=lambda x: x.get('discount_percentage', 0), reverse=True)
            
            # Limit to reasonable number (e.g., top 50 discounted products)
            all_discounted_products = all_discounted_products[:50]
            
            # Türkçe karakter desteği
            return JsonResponse(
                all_discounted_products,
                safe=False,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            import traceback
            print(f"Error in DiscountedProductsAPIView: {e}")
            print(traceback.format_exc())
            return JsonResponse({'error': str(e)}, status=500)

def cheapest_products_by_categories(request):
    """Her marketten belirli 5 kategoriden en ucuz ürünleri döner."""
    try:
        # Define normalized category names
        normalized_categories = {
            "fruits_vegetables": "Meyve ve Sebze",  # All fruit & vegetable variations
            "beverages": "İçecekler",  # All beverage variations
            "meat_poultry_fish": "Et, Tavuk ve Balık",  # All meat variations
            "basic_food": "Temel Gıda",  # All basic food variations
            "frozen_food": "Dondurulmuş Gıda"  # All frozen food variations
        }
        
        # Define mapping from market-specific categories to normalized categories
        category_mapping = {
            # Migros categories
            "Meyve, Sebze": "fruits_vegetables",
            "İçecek": "beverages",
            "Et, Tavuk, Balık": "meat_poultry_fish",
            "Temel Gıda": "basic_food",
            "Dondurulmuş Gıda": "frozen_food",
            
            # Şok Market categories
            "Meyve & Sebze": "fruits_vegetables",
            "İçecek": "beverages",
            "Et & Tavuk & Şarküteri": "meat_poultry_fish",
            "Yemeklik Malzemeler": "basic_food",
            "Dondurulmuş Ürünler": "frozen_food",
            
            # Mopas categories
            "Sebze & Meyve": "fruits_vegetables",
            "İçecekler": "beverages",
            "Kırmızı/Beyaz Et": "meat_poultry_fish",
            "Gıda & Şekerleme": "basic_food",
            
            # Market Paketi categories (all GIDA for now)
            "GIDA": "basic_food",
            
            # Carrefour categories
            "Meyve, Sebze": "fruits_vegetables",
            "İçecekler": "beverages",
            "Et, Tavuk, Balık": "meat_poultry_fish",
            "Temel Gıda": "basic_food",
            "Hazır Yemek&Donuk Ürünler": "frozen_food"
        }
        
        # Define specific categories for each market
        market_categories = {
            "Migros": [
                "Meyve, Sebze",
                "İçecek",
                "Et, Tavuk, Balık",
                "Temel Gıda",
                "Dondurulmuş Gıda"
            ],
            "Şok Market": [
                "Meyve & Sebze",
                "İçecek",
                "Et & Tavuk & Şarküteri",
                "Yemeklik Malzemeler",
                "Dondurulmuş Ürünler"
            ],
            "Mopas": [
                "Sebze & Meyve",
                "İçecekler",
                "Kırmızı/Beyaz Et",
                "Gıda & Şekerleme",
                "Gıda & Şekerleme"
            ],
            "Market Paketi": [
                "GIDA",
                "GIDA",
                "GIDA",
                "GIDA",
                "GIDA"
            ],
            "Carrefour": [
                "Meyve, Sebze",
                "İçecekler",
                "Et, Tavuk, Balık",
                "Temel Gıda",
                "Hazır Yemek&Donuk Ürünler"
            ]
        }
        
        # Products organized by market and category
        results = []
        
        # Process each market separately
        
        # Migros
        try:
            migros_categories = market_categories["Migros"]
            for category in migros_categories:
                # Get products in this category
                category_products = list(MigrosProduct.objects.filter(main_category=category))
                
                if category_products:
                    # Sort by price
                    category_products.sort(key=lambda x: x.price if x.price is not None else float('inf'))
                    
                    # Take up to 4 cheapest products from this category
                    cheapest_products = category_products[:4] if len(category_products) >= 4 else category_products
                    
                    # Get normalized category
                    normalized_category = normalized_categories[category_mapping[category]]
                    
                    # Add each of the cheapest products
                    for product in cheapest_products:
                        results.append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": normalized_category,
                            "original_category": category,
                            "market_name": "Migros"
                        })
        except Exception as e:
            print(f"Error processing Migros categories: {e}")
        
        # Şok Market
        try:
            sok_categories = market_categories["Şok Market"]
            for category in sok_categories:
                # Get products in this category
                category_products = list(SokmarketProduct.objects.filter(main_category=category))
                
                if category_products:
                    # Sort by price
                    category_products.sort(key=lambda x: x.price if x.price is not None else float('inf'))
                    
                    # Take up to 4 cheapest products from this category
                    cheapest_products = category_products[:4] if len(category_products) >= 4 else category_products
                    
                    # Get normalized category
                    normalized_category = normalized_categories[category_mapping[category]]
                    
                    # Add each of the cheapest products
                    for product in cheapest_products:
                        results.append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": normalized_category,
                            "original_category": category,
                            "market_name": "Şok Market"
                        })
        except Exception as e:
            print(f"Error processing Şok Market categories: {e}")
        
        # Mopas
        try:
            mopas_categories = market_categories["Mopas"]
            for category in mopas_categories:
                # Get products in this category
                category_products = list(MopasProduct.objects.filter(main_category=category))
                
                if category_products:
                    # Sort by price
                    category_products.sort(key=lambda x: x.price if x.price is not None else float('inf'))
                    
                    # Take up to 4 cheapest products from this category
                    cheapest_products = category_products[:4] if len(category_products) >= 4 else category_products
                    
                    # Get normalized category
                    normalized_category = normalized_categories[category_mapping[category]]
                    
                    # Add each of the cheapest products
                    for product in cheapest_products:
                        results.append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": normalized_category,
                            "original_category": category,
                            "market_name": "Mopas"
                        })
        except Exception as e:
            print(f"Error processing Mopas categories: {e}")
        
        # Market Paketi
        try:
            marketpaketi_categories = market_categories["Market Paketi"]
            for category in marketpaketi_categories:
                # Get products in this category
                category_products = list(MarketpaketiProduct.objects.filter(main_category=category))
                
                if category_products:
                    # Sort by price
                    category_products.sort(key=lambda x: x.price if x.price is not None else float('inf'))
                    
                    # Take up to 4 cheapest products from this category
                    cheapest_products = category_products[:4] if len(category_products) >= 4 else category_products
                    
                    # Get normalized category
                    normalized_category = normalized_categories[category_mapping[category]]
                    
                    # Add each of the cheapest products
                    for product in cheapest_products:
                        results.append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": normalized_category,
                            "original_category": category,
                            "market_name": "Market Paketi"
                        })
        except Exception as e:
            print(f"Error processing Market Paketi categories: {e}")
        
        # Carrefour
        try:
            carrefour_categories = market_categories["Carrefour"]
            for category in carrefour_categories:
                # Get products in this category
                category_products = list(CarrefourProduct.objects.filter(main_category=category))
                
                if category_products:
                    # Sort by price
                    category_products.sort(key=lambda x: x.price if x.price is not None else float('inf'))
                    
                    # Take up to 4 cheapest products from this category
                    cheapest_products = category_products[:4] if len(category_products) >= 4 else category_products
                    
                    # Get normalized category
                    normalized_category = normalized_categories[category_mapping[category]]
                    
                    # Add each of the cheapest products
                    for product in cheapest_products:
                        results.append({
                            "name": product.name,
                            "price": product.price,
                            "image": product.image_url,
                            "category": normalized_category,
                            "original_category": category,
                            "market_name": "Carrefour"
                        })
        except Exception as e:
            print(f"Error processing Carrefour categories: {e}")
        
        return JsonResponse(results, safe=False)
    except Exception as e:
        import traceback
        print(f"Error in cheapest_products_by_categories: {e}")
        print(traceback.format_exc())
        # Return an empty list instead of an error to prevent the frontend from breaking
        return JsonResponse([], safe=False)    

@api_view(['GET'])
def discounted_products(request):
    """Fetch products that have a high_price greater than their current price"""
    try:
        # Get products from all market tables that have discounts
        discounted_products = []

        # Mopas products with discounts
        mopas_products = MopasProduct.objects.filter(high_price__gt=F('price')).exclude(high_price__isnull=True)
        discounted_products.extend([{
            'id': str(product.id),
            'name': product.name,
            'price': product.price,
            'image_url': product.image_url,
            'main_category': product.main_category,
            'sub_category': product.sub_category,
            'lowest_category': product.lowest_category,
            'market_name': 'Mopas',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in mopas_products])

        # Migros products with discounts
        migros_products = MigrosProduct.objects.filter(high_price__gt=F('price')).exclude(high_price__isnull=True)
        discounted_products.extend([{
            'id': str(product.id),
            'name': product.name,
            'price': product.price,
            'image_url': product.image_url,
            'main_category': product.main_category,
            'sub_category': product.sub_category,
            'lowest_category': product.lowest_category,
            'market_name': 'Migros',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in migros_products])

        # Sokmarket products with discounts
        sokmarket_products = SokmarketProduct.objects.filter(high_price__gt=F('price')).exclude(high_price__isnull=True)
        discounted_products.extend([{
            'id': str(product.id),
            'name': product.name,
            'price': product.price,
            'image_url': product.image_url,
            'main_category': product.main_category,
            'sub_category': product.sub_category,
            'lowest_category': product.lowest_category,
            'market_name': 'Şok Market',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in sokmarket_products])

        # Marketpaketi products with discounts
        marketpaketi_products = MarketpaketiProduct.objects.filter(high_price__gt=F('price')).exclude(high_price__isnull=True)
        discounted_products.extend([{
            'id': str(product.id),
            'name': product.name,
            'price': product.price,
            'image_url': product.image_url,
            'main_category': product.main_category,
            'sub_category': product.sub_category,
            'lowest_category': product.lowest_category,
            'market_name': 'Market Paketi',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in marketpaketi_products])

        # Carrefour products with discounts
        carrefour_products = CarrefourProduct.objects.filter(high_price__gt=F('price')).exclude(high_price__isnull=True)
        discounted_products.extend([{
            'id': str(product.id),
            'name': product.name,
            'price': product.price,
            'image_url': product.image_url,
            'main_category': product.main_category,
            'sub_category': product.sub_category,
            'lowest_category': product.lowest_category,
            'market_name': 'Carrefour',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in carrefour_products])

        # Sort products by discount percentage (highest discount first)
        discounted_products.sort(key=lambda x: (x['high_price'] - x['price']) / x['high_price'], reverse=True)

        return JsonResponse(discounted_products, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)    