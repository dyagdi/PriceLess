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
from .models import Product 
from .serializers import UserSerializer, ProductSerializer 
from django.contrib.postgres.search import SearchQuery, SearchRank, SearchVector



def test_view(request):
    """API'nin çalışıp çalışmadığını test etmek için bir view"""
    return HttpResponse("Server is up and running!")


class UserRegistrationView(generics.CreateAPIView):
    """Kullanıcı kayıt işlemi"""
    queryset = User.objects.all()
    serializer_class = UserSerializer
    permission_classes = [AllowAny]


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
    