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
from .models import FavoriteCartProduct, Product 
from .serializers import UserSerializer, ProductSerializer 
from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector
from .models import FavoriteCart
from .serializers import FavoriteCartSerializer
from rest_framework import permissions
from rest_framework import status
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view





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
            products = Product.objects.all()
            serializer = ProductSerializer(products, many=True)
            return Response(serializer.data, status=200)
        except Exception as e:
            return Response({'error': str(e)}, status=500)


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


def cheapest_products(request):
    """En ucuz 4 ürünü döner."""
    try:
        products = Product.objects.order_by('price')[:8] 
        data = [{"name": p.name, "price": p.price, "image": p.image_url} for p in products]
        return JsonResponse(data, safe=False)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def cheapest_products_per_category(request):
    """Her kategoriden en ucuz 4 ürünü döner."""
    try:
        categories = Product.objects.values_list('main_category', flat=True).distinct()  
        data = []

        for category in categories:
            cheapest_products = (
                Product.objects.filter(main_category=category)
                .order_by('price')[:4]
            )
            data.extend([
                {"name": p.name, "price": p.price, "image": p.image_url, "category": p.main_category}
                for p in cheapest_products
            ])

        return JsonResponse(data, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)        
    
def search_products(request):   # Query sonucuna göre tablodaki ts_vectorden veri çekip Json formtında dönüyor
    query = request.GET.get('q', '')
    
    if query:
        sql_query = """
            SELECT id, name, price, high_price, in_stock, image_url, market_name, product_link
            FROM sample_data
            WHERE search_vector @@ plainto_tsquery('turkish', %s)
        """
        with connection.cursor() as cursor:
            cursor.execute(sql_query, [query])
            results = cursor.fetchall()


        if results:
            data = [
                {
                    'id': row[0],
                    'name': row[1],
                    'price': row[2],
                    'high_price': row[3],
                    'in_stock': row[4],
                    'image_url': row[5],
                    'market_name': row[6],
                    'product_link': row[7],
                }
                for row in results
            ]
            return JsonResponse(data, safe=False)
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
            markets_data = {}
            products = Product.objects.all()
            
            for product in products:
                market_name = product.market_name or "Diğer"
                if market_name not in markets_data:
                    markets_data[market_name] = []
                
                markets_data[market_name].append({
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
            ]

            return JsonResponse(response_data, safe=False)
        except Exception as e:
            print(f"Error in MarketsListAPIView: {e}")
            return JsonResponse({'error': str(e)}, status=500)