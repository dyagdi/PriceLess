from django.urls import path
from . import views

urlpatterns = [
    path('comparison/<str:canonical_name>/', views.product_comparison, name='product_comparison'),
    path('search/<str:product_name>/', views.search_similar_products, name='search_similar_products'),
] 