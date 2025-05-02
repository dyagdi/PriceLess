from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync

class NotificationService:
    def send_notification(self, user, title, body, data=None):
        channel_layer = get_channel_layer()
        message = {
            'type': 'send_notification',
            'message': {
                'title': title,
                'body': body,
                'data': data or {}
            }
        }
        
        async_to_sync(channel_layer.group_send)(
            f'notifications_{user.id}',
            message
        ) 