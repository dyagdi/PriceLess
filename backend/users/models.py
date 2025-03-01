from django.db import models
from django.contrib.postgres.search import SearchVectorField
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
    #search_vector = SearchVectorField(null=True) # Search vector eklentisi

    def __str__(self):
        return self.name

    class Meta:
        db_table = 'sample_data'  # PostgreSQL'deki tablo adı

class FriendRequest(models.Model):
    from_user = models.ForeignKey(User, related_name='sent_requests', on_delete=models.CASCADE)
    to_user = models.ForeignKey(User, related_name='received_requests', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected')
    ], default='pending')

    class Meta:
        unique_together = ('from_user', 'to_user')

class SharedList(models.Model):
    name = models.CharField(max_length=255)
    creator = models.ForeignKey(User, related_name='created_lists', on_delete=models.CASCADE)
    members = models.ManyToManyField(User, related_name='shared_lists')
    created_at = models.DateTimeField(auto_now_add=True)

class SharedListItem(models.Model):
    shared_list = models.ForeignKey(SharedList, related_name='items', on_delete=models.CASCADE)
    name = models.CharField(max_length=255)
    quantity = models.IntegerField(default=1)
    added_by = models.ForeignKey(User, on_delete=models.CASCADE)
    is_purchased = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

