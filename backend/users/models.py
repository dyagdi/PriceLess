from django.db import models
from django.contrib.postgres.search import SearchVectorField

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
    search_vector = SearchVectorField(null=True) # Search vector eklentisi

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'sample_data'  # PostgreSQL'deki tablo adı