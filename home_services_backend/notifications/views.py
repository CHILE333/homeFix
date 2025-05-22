from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from notifications.models import Notification
from accounts.models import User
import json

def create_notification(user_id, title, message, notification_type, related_order_id=None):
    """Helper function to create notifications"""
    try:
        user = User.objects.get(id=user_id)
        notification = Notification.objects.create(
            user=user,
            title=title,
            message=message,
            notification_type=notification_type,
            related_order_id=related_order_id
        )
        return notification
    except User.DoesNotExist:
        return None

@csrf_exempt
def get_notifications(request, user_id):
    """API endpoint to get user notifications"""
    if request.method == 'GET':
        notifications = Notification.objects.filter(user_id=user_id)
        data = []
        for notification in notifications:
            data.append({
                'id': notification.id,
                'title': notification.title,
                'message': notification.message,
                'notification_type': notification.notification_type,
                'is_read': notification.is_read,
                'created_at': notification.created_at.isoformat(),
                'related_order_id': notification.related_order_id
            })
        return JsonResponse({'notifications': data})

@csrf_exempt
def mark_notification_read(request, notification_id):
    """API endpoint to mark notification as read"""
    if request.method == 'POST':
        try:
            notification = Notification.objects.get(id=notification_id)
            notification.is_read = True
            notification.save()
            return JsonResponse({'success': True})
        except Notification.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Notification not found'})