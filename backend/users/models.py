from django.db import models
# Commenting out SearchVectorField as we're not using it temporarily
# from django.contrib.postgres.search import SearchVectorField
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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'sample_data'  # PostgreSQL'deki tablo adı

class FavoriteCart(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    id = models.AutoField(primary_key=True)  # Django automatically assigns an ID, so no need for shopping_cart_id separately.

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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    class Meta:
        db_table = 'mopas_2_products'

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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    class Meta:
        db_table = 'migros_2_products'

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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    class Meta:
        db_table = 'sokmarket_2_products'

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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    class Meta:
        db_table = 'marketpaketi_2_products'

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
    # Make search_vector truly optional
    # search_vector = SearchVectorField(null=True, blank=True)

    class Meta:
        db_table = 'carrefour_2_products'
