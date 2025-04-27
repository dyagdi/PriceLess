from django.urls import path
from .views import (
    test_view, 
    UserRegistrationView, 
    user_login, 
    ProductListAPIView, 
    HomePageProductListAPIView, 
    cheapest_products,
    MarketsListAPIView,
    DiscountedProductsAPIView,
)
from . import views
from .views import FavoriteCartListCreateView


urlpatterns = [
    path('test/', test_view, name='test'),
    path('users/register/', UserRegistrationView.as_view(), name='register'),
    path('users/login/', user_login, name='login'),
    path('products/', ProductListAPIView.as_view(), name='product-list'),
    path('products/filtered/', HomePageProductListAPIView.as_view(), name='filtered-product-list'),
    path('cheapest-products/', views.cheapest_products, name='cheapest-products'),
    path('cheapest-products-per-category/', views.cheapest_products_per_category, name='cheapest-products-per-category'),
    path('search/', views.search_products, name='search_products'), # verilerin tablodan çekilebilmesi için eklediğim endpoint
    path('favorite-carts/', FavoriteCartListCreateView.as_view(), name='favorite-carts'),
    path('markets-products/', MarketsListAPIView.as_view(), name='market-products'),
    path('discounted-products/', DiscountedProductsAPIView.as_view(), name='discounted-products'),
]