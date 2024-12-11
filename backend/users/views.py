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
                {"name": p.name, "price": p.price, "image": p.image_url, "category": p.main_category}
                for p in cheapest_products
            ])

        return JsonResponse(data, safe=False)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)        