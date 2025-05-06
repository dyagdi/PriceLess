import logging
import json
import secrets
import datetime
import ssl
import traceback
from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from django.db import transaction, connection
from django.http import HttpResponse, JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings
from django.utils import timezone
from django.core.mail import get_connection, EmailMessage
from rest_framework import generics, status, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from django.db.models import F
from itertools import chain
import requests
from geopy.geocoders import Nominatim
from geopy.distance import geodesic
from urllib.parse import quote

from .models import (
    FavoriteCart, Product, FavoriteCartProduct, MopasProduct, MigrosProduct,
    SokmarketProduct, MarketpaketiProduct, CarrefourProduct, UserAddress,
    UserPhoneNumber, ShoppingList, ShoppingListItem, Invitation
)
from .serializers import (
    UserSerializer, FavoriteCartSerializer, ProductSerializer,
    UserAddressSerializer, ShoppingListSerializer, ShoppingListItemSerializer,
    MopasProductSerializer, MigrosProductSerializer, SokmarketProductSerializer,
    MarketpaketiProductSerializer, CarrefourProductSerializer
)

# Configure logger
logger = logging.getLogger(__name__)

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
                            "market_name": "mopas"  # Add market name
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
                            "market_name": "migros"  # Add market name
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
                            "market_name": "sokmarket"  # Add market name
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
                            "market_name": "marketpaketi"  # Add market name
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
                            "market_name": "carrefour"  # Add market name
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
                            "market_name": "mopas"
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
                            "market_name": "migros"
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
                            "market_name": "sokmarket"
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
                            "market_name": "marketpaketi"
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
                            "market_name": "carrefour"
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
            ('mopas_products', MopasProduct, "mopas"),
            ('migros_products', MigrosProduct, "migros"),
            ('sokmarket_products', SokmarketProduct, "sokmarket"),
            ('marketpaketi_products', MarketpaketiProduct, "marketpaketi"),
            ('carrefour_products', CarrefourProduct, "carrefour")
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

    def create(self, request, *args, **kwargs):
        try:
            user = request.user
            cart_data = request.data.get('products', [])
            cart_name = request.data.get('name', None)
            
            favorite_cart = FavoriteCart.objects.create(
                user=user,
                name=cart_name
            )
            
            for product in cart_data:
                FavoriteCartProduct.objects.create(
                    favorite_cart=favorite_cart,
                    user=user,
                    name=product['name'],
                    price=product['price'],
                    image=product['image'],
                    quantity=product['quantity']
                )

            return JsonResponse({
                "message": "Sepetiniz başarıyla favorilere kaydedildi!",
                "cart_id": favorite_cart.id
            }, status=status.HTTP_201_CREATED, json_dumps_params={'ensure_ascii': False})
        except Exception as e:
            print(f"Error in create: {str(e)}")
            return JsonResponse({
                "error": str(e)
            }, status=status.HTTP_400_BAD_REQUEST, json_dumps_params={'ensure_ascii': False})

    def list(self, request, *args, **kwargs):
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return JsonResponse(
                serializer.data,
                safe=False,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            print(f"Error in list view: {str(e)}") 
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )

class DeleteFavoriteCartView(generics.DestroyAPIView):
    serializer_class = FavoriteCartSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return FavoriteCart.objects.filter(user=self.request.user)

    def destroy(self, request, *args, **kwargs):
        try:
            instance = self.get_object()
            self.perform_destroy(instance)
            return JsonResponse({
                "message": "Sepet başarıyla silindi!"
            }, status=status.HTTP_200_OK, json_dumps_params={'ensure_ascii': False})
        except Exception as e:
            print(f"Error in destroy: {str(e)}")  
            return JsonResponse({
                "error": str(e)
            }, status=status.HTTP_400_BAD_REQUEST, json_dumps_params={'ensure_ascii': False})

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
                            "market_name": "migros"
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
                            "market_name": "sokmarket"
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
                            "market_name": "mopas"
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
                            "market_name": "marketpaketi"
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
                            "market_name": "carrefour"
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
            'market_name': 'mopas',
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
            'market_name': 'migros',
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
            'market_name': 'sokmarket',
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
            'market_name': 'marketpaketi',
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
            'market_name': 'carrefour',
            'high_price': product.high_price,
            'product_link': product.product_link
        } for product in carrefour_products])

        # Sort products by discount percentage (highest discount first)
        discounted_products.sort(key=lambda x: (x['high_price'] - x['price']) / x['high_price'], reverse=True)

        return JsonResponse(discounted_products, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)    
    
    
class UserInfoView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        try:
            phone_number = UserPhoneNumber.objects.get(user=user).phone_number
        except UserPhoneNumber.DoesNotExist:
            phone_number = None

        return Response({
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone_number': phone_number
        })

    def put(self, request):
        user = request.user
        first_name = request.data.get('first_name')
        last_name = request.data.get('last_name')
        phone_number = request.data.get('phone_number')

        if first_name:
            user.first_name = first_name
        if last_name:
            user.last_name = last_name
        user.save()

        if phone_number is not None:
            phone_obj, created = UserPhoneNumber.objects.get_or_create(user=user)
            phone_obj.phone_number = phone_number
            phone_obj.save()

        return Response({
            'email': user.email,
            'first_name': user.first_name,
            'last_name': user.last_name,
            'phone_number': phone_number
        })

class UserAddressView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = UserAddressSerializer

    def get(self, request):
        try:
            addresses = UserAddress.objects.filter(user=request.user)
            serializer = UserAddressSerializer(addresses, many=True)
            return JsonResponse(
                serializer.data,
                safe=False,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            print(f"Error in get addresses: {str(e)}") 
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )

    def post(self, request):
        try:
            serializer = UserAddressSerializer(data=request.data)
            if serializer.is_valid():
                serializer.save(user=request.user)
                return JsonResponse(
                    serializer.data,
                    status=status.HTTP_201_CREATED,
                    json_dumps_params={'ensure_ascii': False}
                )
            return JsonResponse(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            print(f"Error in post address: {str(e)}")  
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )

    def put(self, request, address_id):
        try:
            address = UserAddress.objects.get(id=address_id, user=request.user)
            serializer = UserAddressSerializer(address, data=request.data)
            if serializer.is_valid():
                serializer.save()
                return JsonResponse(
                    serializer.data,
                    status=status.HTTP_200_OK,
                    json_dumps_params={'ensure_ascii': False}
                )
            return JsonResponse(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )
        except UserAddress.DoesNotExist:
            return JsonResponse(
                {'error': 'Adres bulunamadı'},
                status=status.HTTP_404_NOT_FOUND,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            print(f"Error in put address: {str(e)}")  
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )

    def delete(self, request, address_id):
        try:
            address = UserAddress.objects.get(id=address_id, user=request.user)
            address.delete()
            return JsonResponse(
                {'message': 'Adres başarıyla silindi'},
                status=status.HTTP_200_OK,
                json_dumps_params={'ensure_ascii': False}
            )
        except UserAddress.DoesNotExist:
            return JsonResponse(
                {'error': 'Adres bulunamadı'},
                status=status.HTTP_404_NOT_FOUND,
                json_dumps_params={'ensure_ascii': False}
            )
        except Exception as e:
            print(f"Error in delete address: {str(e)}")  
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )    

class ChangePasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        try:
            user = request.user
            current_password = request.data.get('current_password')
            new_password = request.data.get('new_password')
            confirm_password = request.data.get('confirm_password')

            print(f"Password change attempt for user: {user.username}")
            print(f"Request data: {request.data}")
            print(f"Request headers: {request.headers}")

            if not current_password or not new_password or not confirm_password:
                print("Missing required fields")
                print(f"Current password: {bool(current_password)}")
                print(f"New password: {bool(new_password)}")
                print(f"Confirm password: {bool(confirm_password)}")
                return JsonResponse(
                    {'error': 'Tüm alanları doldurunuz'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )

            print("Checking current password...")
            if not user.check_password(current_password):
                print("Current password check failed")
                return JsonResponse(
                    {'error': 'Mevcut şifre yanlış'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )
            print("Current password check passed")

            if new_password != confirm_password:
                print("New passwords do not match")
                return JsonResponse(
                    {'error': 'Yeni şifreler eşleşmiyor'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )

            if len(new_password) < 6:
                print("New password too short")
                return JsonResponse(
                    {'error': 'Yeni şifre en az 6 karakter olmalıdır'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )

            print("Setting new password...")
            user.set_password(new_password)
            user.save(update_fields=['password'])  
            
            print("Verifying password change...")
            user.refresh_from_db()  
            if not user.check_password(new_password):
                print("Password change verification failed")
                return JsonResponse(
                    {'error': 'Şifre değiştirme işlemi başarısız oldu'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    json_dumps_params={'ensure_ascii': False}
                )

            print("Password changed successfully")
            return JsonResponse(
                {'message': 'Şifreniz başarıyla değiştirildi'},
                status=status.HTTP_200_OK,
                json_dumps_params={'ensure_ascii': False}
            )

        except Exception as e:
            print(f"Error in change password: {str(e)}")
            print(f"Error type: {type(e)}")
            import traceback
            print(f"Traceback: {traceback.format_exc()}")
            return JsonResponse(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST,
                json_dumps_params={'ensure_ascii': False}
            )    

class DeleteAccountView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request):
        try:
            user = request.user
            logger.info(f"Attempting to delete account for user: {user.id}")

            with transaction.atomic():
                
                UserAddress.objects.filter(user=user).delete()
                FavoriteCart.objects.filter(user=user).delete()
                FavoriteCartProduct.objects.filter(user=user).delete()
                UserPhoneNumber.objects.filter(user=user).delete()
                
                
                Token.objects.filter(user=user).delete()
                
               
                user.delete()
                
                logger.info(f"Successfully deleted account for user: {user.id}")
                return JsonResponse(
                    {'message': 'Hesabınız başarıyla silindi'},
                    status=status.HTTP_200_OK,
                    json_dumps_params={'ensure_ascii': False}
                )
        except Exception as e:
            logger.error(f"Error deleting account for user {user.id}: {str(e)}")
            return JsonResponse(
                {'error': 'Hesap silinirken bir hata oluştu'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                json_dumps_params={'ensure_ascii': False}
            )    


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            email = request.data.get('email')
            if not email:
                return JsonResponse(
                    {'error': 'Email adresi gereklidir'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return JsonResponse(
                    {'error': 'Bu email adresi ile kayıtlı kullanıcı bulunamadı'},
                    status=status.HTTP_404_NOT_FOUND,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            # Generate a random token
            reset_token = secrets.token_urlsafe(32)
            # Set token expiry to 1 hour from now
            token_expiry = timezone.now() + datetime.timedelta(hours=1)
            
            # Store the reset token and expiry in user's session
            request.session[f'reset_token_{user.id}'] = {
                'token': reset_token,
                'expiry': token_expiry.isoformat()
            }
            
            # Send reset email
            reset_link = f"http://localhost:3000/reset-password?token={reset_token}&email={email}"
            email_body = f"""
            Merhaba,
            
            Şifrenizi sıfırlamak için aşağıdaki bağlantıya tıklayın:
            
            {reset_link}
            
            Bu bağlantı 1 saat içinde geçerliliğini yitirecektir.
            
            Eğer şifre sıfırlama talebinde bulunmadıysanız, bu e-postayı göz ardı edebilirsiniz.
            
            Saygılarımızla,
            PriceLess Ekibi
            """
            
            try:
                # ⚡ Create an SSL context that does NOT verify certificates
                ssl_context = ssl._create_unverified_context()
                
                # ⚡ Create email connection using the "unverified" context
                connection = get_connection(
                    use_tls=True,  # or use_ssl=True if your SMTP server expects SSL directly
                    ssl_context=ssl_context,
                )
                
                email_message = EmailMessage(
                    subject='PriceLess Şifre Sıfırlama',
                    body=email_body,
                    from_email=settings.EMAIL_HOST_USER,
                    to=[email],
                    connection=connection,
                )
                email_message.send(fail_silently=False)
                
                return JsonResponse(
                    {'message': 'Şifre sıfırlama bağlantısı email adresinize gönderildi'},
                    status=status.HTTP_200_OK,
                    json_dumps_params={'ensure_ascii': False}
                )
                
            except Exception as email_error:
                logger.error(f"Email sending error: {str(email_error)}")
                return JsonResponse(
                    {'error': 'Email gönderilirken bir hata oluştu. Lütfen daha sonra tekrar deneyin.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    json_dumps_params={'ensure_ascii': False}
                )
        
        except Exception as e:
            logger.error(f"Error in forgot password: {str(e)}")
            return JsonResponse(
                {'error': 'Şifre sıfırlama işlemi sırasında bir hata oluştu'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                json_dumps_params={'ensure_ascii': False}
            )
            
class ResetPasswordView(APIView):
    permission_classes = [AllowAny]
    
    def post(self, request):
        try:
            token = request.data.get('token')
            email = request.data.get('email')
            new_password = request.data.get('new_password')
            
            if not all([token, email, new_password]):
                return JsonResponse(
                    {'error': 'Token, email ve yeni şifre gereklidir'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            try:
                user = User.objects.get(email=email)
            except User.DoesNotExist:
                return JsonResponse(
                    {'error': 'Geçersiz kullanıcı'},
                    status=status.HTTP_404_NOT_FOUND,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            stored_data = request.session.get(f'reset_token_{user.id}')
            if not stored_data or stored_data['token'] != token:
                return JsonResponse(
                    {'error': 'Geçersiz veya süresi dolmuş token'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            expiry = datetime.datetime.fromisoformat(stored_data['expiry'])
            if timezone.now() > expiry:
                del request.session[f'reset_token_{user.id}']
                return JsonResponse(
                    {'error': 'Token süresi dolmuş'},
                    status=status.HTTP_400_BAD_REQUEST,
                    json_dumps_params={'ensure_ascii': False}
                )
            
            user.set_password(new_password)
            user.save()
            
            del request.session[f'reset_token_{user.id}']
            
            return JsonResponse(
                {'message': 'Şifreniz başarıyla değiştirildi'},
                status=status.HTTP_200_OK,
                json_dumps_params={'ensure_ascii': False}
            )
            
        except Exception as e:
            logger.error(f"Error in reset password: {str(e)}")
            return JsonResponse(
                {'error': 'Şifre sıfırlama işlemi sırasında bir hata oluştu'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
                json_dumps_params={'ensure_ascii': False}
            )    
            
            
           
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_shopping_lists(request):
    shopping_lists = ShoppingList.objects.filter(members=request.user)
    data = [{'id': sl.id, 'name': sl.name} for sl in shopping_lists]
    return Response({'shopping_lists': data}, status=status.HTTP_200_OK)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_shopping_list(request):
    name = request.data.get('name')
    if not name:
        return Response({'error': 'Name is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    shopping_list = ShoppingList.objects.create(
        name=name,
        owner=request.user
    )
    shopping_list.members.add(request.user) 
    serializer = ShoppingListSerializer(shopping_list)
    return Response(serializer.data, status=status.HTTP_201_CREATED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_shopping_list_details(request, list_id):
    try:
        shopping_list = ShoppingList.objects.get(id=list_id, members=request.user)
        serializer = ShoppingListSerializer(shopping_list)
        return Response(serializer.data)
    except ShoppingList.DoesNotExist:
        return Response({'error': 'Shopping list not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_shopping_list(request, list_id):
    try:
        shopping_list = ShoppingList.objects.get(id=list_id, owner=request.user)
        shopping_list.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except ShoppingList.DoesNotExist:
        return Response({'error': 'Shopping list not found or unauthorized'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_shopping_list_items(request, list_id):
    try:
        shopping_list = ShoppingList.objects.get(id=list_id, members=request.user)
        items = ShoppingListItem.objects.filter(shopping_list=shopping_list)
        serializer = ShoppingListItemSerializer(items, many=True)
        return Response(serializer.data)
    except ShoppingList.DoesNotExist:
        return Response({'error': 'Shopping list not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_shopping_list_item(request, list_id):
    try:
        shopping_list = ShoppingList.objects.get(id=list_id, members=request.user)
        name = request.data.get('name')
        if not name:
            return Response({'error': 'Name is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        item = ShoppingListItem.objects.create(
            shopping_list=shopping_list,
            name=name,
            added_by=request.user
        )
        serializer = ShoppingListItemSerializer(item)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    except ShoppingList.DoesNotExist:
        return Response({'error': 'Shopping list not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def toggle_item_status(request, item_id):
    try:
        item = ShoppingListItem.objects.get(
            id=item_id,
            shopping_list__members=request.user
        )
        item.is_done = not item.is_done
        item.save()
        serializer = ShoppingListItemSerializer(item)
        return Response(serializer.data)
    except ShoppingListItem.DoesNotExist:
        return Response({'error': 'Item not found'}, status=status.HTTP_404_NOT_FOUND)
    
@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_shopping_list_item(request, item_id):
    try:
        item = ShoppingListItem.objects.get(
            id=item_id,
            shopping_list__members=request.user
        )
        item.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except ShoppingListItem.DoesNotExist:
        return Response({'error': 'Item not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def add_member_to_list(request, list_id):
    email = request.data.get('email')
    try:
        shopping_list = ShoppingList.objects.get(id=list_id, members=request.user)
        new_member = User.objects.get(email=email)
        
        invitation = Invitation.objects.create(
            sender=request.user,
            receiver=new_member,
            shopping_list=shopping_list
        )
        
        try:
            # Try to use Channels if available
            channel_layer = get_channel_layer()
            if channel_layer is not None:
                async_to_sync(channel_layer.group_send)(
                    f"notifications_{new_member.id}",
                    {
                        "type": "notification_message",
                        "message": {
                            "title": "Ortak Alışveriş Listesi Davetleri",
                            "body": f"{request.user.username} seni '{shopping_list.name}' ortak alışveriş listesine davet etti",
                            "type": "invitation",
                            "invitation_id": invitation.id,
                            "shopping_list_id": shopping_list.id,
                            "shopping_list_name": shopping_list.name
                        }
                    }
                )
        except Exception as e:
            # Log the error but don't fail the request
            logger.error(f"Error sending notification: {str(e)}")
        
        return Response({'message': 'İstek başarıyla gönderildi'}, status=status.HTTP_200_OK)
    except ShoppingList.DoesNotExist:
        return Response({'error': 'Alışveriş listesi bulunamadı'}, status=status.HTTP_404_NOT_FOUND)
    except User.DoesNotExist:
        return Response({'error': 'Kullanıcı bulunamadı'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def respond_to_invitation(request):
    invitation_id = request.data.get('invitation_id')
    action = request.data.get('action')  
    
    try:
        invitation = Invitation.objects.get(id=invitation_id, receiver=request.user)
        
        if action == 'accept':
            invitation.status = 'accepted'
            invitation.shopping_list.members.add(request.user)
            message = 'Invitation accepted'
        else:
            invitation.status = 'declined'
            message = 'Invitation declined'
            
        invitation.save()
        
        try:
            channel_layer = get_channel_layer()
            if channel_layer is not None:
                async_to_sync(channel_layer.group_send)(
                    f"notifications_{invitation.sender.id}",
                    {
                        "type": "notification_message",
                        "message": {
                            "title": "Invitation Response",
                            "body": f"{request.user.username} {action}ed your invitation to '{invitation.shopping_list.name}'",
                            "type": "invitation_response"
                        }
                    }
                )
        except Exception as e:
            # Log the error but don't fail the request
            logger.error(f"Error sending notification: {str(e)}")
        
        return Response({'message': message}, status=status.HTTP_200_OK)
    except Invitation.DoesNotExist:
        return Response({'error': 'Invitation not found'}, status=status.HTTP_404_NOT_FOUND)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_pending_invitations(request):
    invitations = Invitation.objects.filter(receiver=request.user, status='pending')
    data = [{
        'id': inv.id,
        'shopping_list_id': inv.shopping_list.id,
        'shopping_list_name': inv.shopping_list.name,
        'sender_name': inv.sender.username,
        'created_at': inv.created_at
    } for inv in invitations]
    return Response({'invitations': data}, status=status.HTTP_200_OK)

class NearbyMarketsWithPricesAPIView(APIView):
    """API endpoint for retrieving nearby markets with their price data"""
    def get(self, request):
        try:
            # Get query parameters
            latitude = float(request.query_params.get('latitude', 0))
            longitude = float(request.query_params.get('longitude', 0))
            radius = int(request.query_params.get('radius', 1500))  # Default 1.5km

            # Get all products from each market to calculate total prices
            market_products = {
                "mopas": MopasProduct.objects.all(),
                "migros": MigrosProduct.objects.all(),
                "sokmarket": SokmarketProduct.objects.all(),
                "marketpaketi": MarketpaketiProduct.objects.all(),
                "carrefour": CarrefourProduct.objects.all()
            }

            # Calculate total prices for each market
            market_prices = {}
            for market_name, products in market_products.items():
                total_price = sum(product.price for product in products if product.price is not None)
                market_prices[market_name] = total_price

            # Fetch nearby markets using Overpass API
            overpass_query = f"""
            [out:json];
            (
              node["shop"="supermarket"](around:{radius},{latitude},{longitude});
              node["shop"="grocery"](around:{radius},{latitude},{longitude});
              node["amenity"="marketplace"](around:{radius},{latitude},{longitude});
            );
            out;
            """

            url = "https://overpass-api.de/api/interpreter?data=" + quote(overpass_query)
            response = requests.get(url)
            
            if response.status_code == 200:
                data = response.json()
                elements = data.get("elements", [])
                
                # Process and combine market data
                markets = []
                for element in elements:
                    market_name = (
                        element.get("tags", {}).get("name") or
                        element.get("tags", {}).get("brand") or
                        element.get("tags", {}).get("shop") or
                        element.get("tags", {}).get("amenity") or
                        "Unnamed Market"
                    )
                    
                    # Calculate distance using geodesic
                    user_location = (latitude, longitude)
                    market_location = (element["lat"], element["lon"])
                    distance = geodesic(user_location, market_location).kilometers
                    
                    # Find matching market in our database
                    market_key = None
                    for key in market_prices.keys():
                        if key.lower() in market_name.lower():
                            market_key = key
                            break
                    
                    # Ensure all values are non-null
                    market_data = {
                        "name": market_name,
                        "latitude": float(element["lat"]),
                        "longitude": float(element["lon"]),
                        "distance": float(distance),
                        "total_price": float(market_prices.get(market_key, 0)) if market_key else 0.0,
                        "has_price_data": bool(market_key is not None),
                        "is_open": True,  # Default to True since we don't have this data
                        "rating": 0.0,    # Default rating
                        "address": element.get("tags", {}).get("addr:full", "") or element.get("tags", {}).get("address", "") or ""
                    }
                    
                    markets.append(market_data)
                
                # Sort by distance
                markets.sort(key=lambda x: x["distance"])
                
                return Response(markets, status=200)
            else:
                return Response(
                    {"error": "Failed to fetch nearby markets"},
                    status=500
                )
                
        except Exception as e:
            print(f"Error in NearbyMarketsWithPricesAPIView: {str(e)}")
            return Response(
                {"error": str(e)},
                status=500
            )
