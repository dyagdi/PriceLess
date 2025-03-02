from django.db import connection
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(['GET'])
def product_comparison(request, canonical_name):
    try:
        # Query the price_comparison view for this canonical name
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT * FROM price_comparison 
                WHERE canonical_name = %s
            """, [canonical_name])
            result = cursor.fetchone()
            
            if result:
                # Convert to dictionary
                columns = [col[0] for col in cursor.description]
                comparison_data = dict(zip(columns, result))
                return JsonResponse(comparison_data)
            else:
                return JsonResponse({"error": "Product not found"}, status=404)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500) 