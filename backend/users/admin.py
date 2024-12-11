from django.contrib import admin
from .models import Product

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('main_category', 'sub_category', 'lowest_category', 'name', 'price', 'high_price', 'in_stock', 'product_link', 'image_url', 'page_link', 'date','market_name' )  # Admin panelindeki sütunlar


