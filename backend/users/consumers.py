import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth.models import User
from rest_framework.authtoken.models import Token

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        # Get the token from the query parameters
        token = self.scope['query_string'].decode().split('=')[1]
        
        # Authenticate the user
        user = await self.get_user_from_token(token)
        if user:
            self.user = user
            await self.channel_layer.group_add(
                f"notifications_{user.id}",
                self.channel_name
            )
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        if hasattr(self, 'user'):
            await self.channel_layer.group_discard(
                f"notifications_{self.user.id}",
                self.channel_name
            )

    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        await self.channel_layer.group_send(
            f"notifications_{self.user.id}",
            {
                'type': 'notification_message',
                'message': message
            }
        )

    async def notification_message(self, event):
        message = event['message']
        await self.send(text_data=json.dumps({
            'message': message
        }))

    @database_sync_to_async
    def get_user_from_token(self, token):
        try:
            token_obj = Token.objects.get(key=token)
            return token_obj.user
        except Token.DoesNotExist:
            return None 