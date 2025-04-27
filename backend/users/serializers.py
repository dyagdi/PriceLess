from rest_framework import serializers
from django.contrib.auth.models import User
from .models import FavoriteCart, Product, FavoriteCartProduct, MopasProduct, MigrosProduct, SokmarketProduct, MarketpaketiProduct, CarrefourProduct

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['email', 'password', 'first_name', 'last_name']
    
    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['email'],
            email=validated_data['email'],
            password=validated_data['password'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name']
        )
        return user

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = '__all__'

# New serializers for each market
class MopasProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = MopasProduct
        fields = '__all__'

class MigrosProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = MigrosProduct
        fields = '__all__'

class SokmarketProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = SokmarketProduct
        fields = '__all__'

class MarketpaketiProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = MarketpaketiProduct
        fields = '__all__'

class CarrefourProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = CarrefourProduct
        fields = '__all__'
        
class FavoriteCartProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = FavoriteCartProduct
        fields = ['name', 'price', 'image', 'quantity']

class FavoriteCartSerializer(serializers.ModelSerializer):
    products = serializers.SerializerMethodField()

    class Meta:
        model = FavoriteCart
        fields = ['id', 'user', 'products']
        read_only_fields = ['user']

    def get_products(self, obj):
        # Get products through the foreign key relationship
        cart_products = FavoriteCartProduct.objects.filter(favorite_cart_id=obj.id)
        return FavoriteCartProductSerializer(cart_products, many=True).data
