from rest_framework import serializers
from django.contrib.auth.models import User
from .models import FavoriteCart, Product, FavoriteCartProduct, MopasProduct, MigrosProduct, SokmarketProduct, MarketpaketiProduct, CarrefourProduct,  UserAddress, ShoppingList,ShoppingListItem

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

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if 'name' in data:
            data['name'] = data['name'].encode('utf-8').decode('utf-8')
        return data

class FavoriteCartSerializer(serializers.ModelSerializer):
    products = serializers.SerializerMethodField()

    class Meta:
        model = FavoriteCart
        fields = ['id', 'user', 'products', 'name']
        read_only_fields = ['user']

    def get_products(self, obj):
        cart_products = FavoriteCartProduct.objects.filter(favorite_cart_id=obj.id)
        return FavoriteCartProductSerializer(cart_products, many=True).data

    def to_representation(self, instance):
        data = super().to_representation(instance)
   
        if 'products' in data:
            for product in data['products']:
                if 'name' in product:
                    product['name'] = product['name'].encode('utf-8').decode('utf-8')
        return data
    
class UserAddressSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserAddress
        fields = ['id', 'country', 'city', 'state', 'address_title', 'address_details', 'postal_code', 'mahalle']
        read_only_fields = ['user']

    def to_representation(self, instance):
        data = super().to_representation(instance)
        
        for field in ['country', 'city', 'state', 'address_title', 'address_details', 'mahalle']:
            if field in data and data[field]:
                data[field] = data[field].encode('utf-8').decode('utf-8')
        return data
    
    
class ShoppingListSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    members = serializers.SerializerMethodField()
    
    def get_members(self, obj):
        return [
            {
                'id': member.id,
                'username': member.username,
                'email': member.email,
                'name': f"{member.first_name} {member.last_name}".strip() or member.username
            }
            for member in obj.members.all()
        ]

    class Meta:
        model = ShoppingList
        fields = ['id', 'name', 'owner', 'members', 'created_at']


class ShoppingListItemSerializer(serializers.ModelSerializer):
    added_by = serializers.ReadOnlyField(source='added_by.username')
    
    class Meta:
        model = ShoppingListItem
        fields = ['id', 'shopping_list', 'name', 'is_done', 'added_by', 'created_at']
