from django.db import models

from django.contrib.auth.models import User


class Product(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()  
    high_price = models.FloatField(null=True, blank=True)  
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()


    def __str__(self):
        return self.name

    class Meta:
        db_table = 'sample_data'  # PostgreSQL'deki tablo adı

class FavoriteCart(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    id = models.AutoField(primary_key=True) 
    name = models.CharField(max_length=255, null=True, blank=True) 

    class Meta:
        db_table = 'favorite_carts'

class FavoriteCartProduct(models.Model):
    favorite_cart = models.ForeignKey(FavoriteCart, on_delete=models.CASCADE)
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image = models.URLField()
    quantity = models.PositiveIntegerField()

    class Meta:
        db_table = 'favorite_carts_products'

    def __str__(self):
        return f"{self.name} (x{self.quantity}) - Cart {self.favorite_cart_id}"

class MopasProduct(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()


    class Meta:
        db_table = 'mopas_3_products'

class MigrosProduct(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()
   

    class Meta:
        db_table = 'migros_3_products'
class A101Product(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()
    
    class Meta:
        db_table = 'a101_3_products'

class SokmarketProduct(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()
    

    class Meta:
        db_table = 'sokmarket_3_products'

class MarketpaketiProduct(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()
 

    class Meta:
        db_table = 'marketpaketi_3_products'

class CarrefourProduct(models.Model):
    main_category = models.TextField()
    sub_category = models.TextField()
    lowest_category = models.TextField()
    name = models.TextField()
    price = models.FloatField()
    high_price = models.FloatField(null=True, blank=True)
    in_stock = models.TextField()
    product_link = models.TextField()
    page_link = models.TextField()
    image_url = models.TextField()
    date = models.TextField()
    market_name = models.TextField()
 

    class Meta:
        db_table = 'carrefour_3_products'
        
class UserPhoneNumber(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone_number = models.CharField(max_length=20, blank=True, null=True)

    class Meta:
        db_table = 'user_phone_numbers'

    def __str__(self):
        return f"{self.user.username}'s phone: {self.phone_number}"
    
    
class UserAddress(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    country = models.CharField(max_length=100)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    address_title = models.CharField(max_length=100)
    address_details = models.TextField()
    postal_code = models.CharField(max_length=20)
    mahalle = models.CharField(max_length=100)

    class Meta:
        db_table = 'user_addresses'

    def __str__(self):
        return f"{self.user.username}'s address: {self.address_title}"
    
class ShoppingList(models.Model):
   name = models.CharField(max_length=255)
   owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_lists')
   members = models.ManyToManyField(User, related_name='shared_lists')
   created_at = models.DateTimeField(auto_now_add=True)


   def __str__(self):
       return self.name
  
   class Meta:
       db_table = 'shopping_list'


class ShoppingListItem(models.Model):
    shopping_list = models.ForeignKey(ShoppingList, on_delete=models.CASCADE, related_name='items')
    name = models.CharField(max_length=255)
    is_done = models.BooleanField(default=False)
    added_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    def __str__(self):
        return self.name

    class Meta:
        db_table = 'shopping_list_item'
        
class Invitation(models.Model):
    sender = models.ForeignKey(User, related_name='sent_invitations', on_delete=models.CASCADE)
    receiver = models.ForeignKey(User, related_name='received_invitations', on_delete=models.CASCADE)
    shopping_list = models.ForeignKey(ShoppingList, on_delete=models.CASCADE)
    status = models.CharField(max_length=10, choices=[('pending', 'Pending'), ('accepted', 'Accepted'), ('declined', 'Declined')], default='pending')
    created_at = models.DateTimeField(auto_now_add=True)


    def __str__(self):
        return f"{self.sender} invited {self.receiver} to {self.shopping_list} ({self.status})"

    class Meta:
        db_table = 'shopping_list_invitations'


