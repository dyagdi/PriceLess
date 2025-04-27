from django.core.management.base import BaseCommand
# Commenting out SearchVector import as we're not using it temporarily
# from django.contrib.postgres.search import SearchVector
from users.models import Product  

class Command(BaseCommand):
    help = 'Update search_vector field for products'

    def handle(self, *args, **kwargs):
        # Commented out search_vector update as we're not using it temporarily
        # Product.objects.update(search_vector=SearchVector('name', 'main_category', 'market_name', config='turkish'))
        self.stdout.write(self.style.SUCCESS('Search vector update skipped as functionality is temporarily disabled.'))
