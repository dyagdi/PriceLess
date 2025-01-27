from django.core.management.base import BaseCommand
from django.contrib.postgres.search import SearchVector
from ...models import Product  

class Command(BaseCommand):
    help = 'Update search_vector field for products'

    def handle(self, *args, **kwargs):
        Product.objects.update(search_vector=SearchVector('name', 'main_category', 'market_name', config='turkish'))
        self.stdout.write(self.style.SUCCESS('Successfully updated search_vector for all products.'))
