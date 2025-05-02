"""
URL configuration for PriceLess project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path, include 
from django.http import HttpResponse
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from django.core.asgi import get_asgi_application
from .routing import websocket_urlpatterns

def welcome_view(request):
    return HttpResponse("<h1>Welcome to the PriceLess API</h1>")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', welcome_view, name='home'),  # Ana sayfa rotası
    path('api/', include('users.urls')),  # API için users rotası
]

# WebSocket routing
application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})


