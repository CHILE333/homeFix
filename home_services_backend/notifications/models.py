from django.db import models
from accounts.models import User
from orders.models import Order

class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('new_order', 'New Order'),
        ('order_status', 'Order Status Update'),
        ('message', 'New Message'),
        ('system', 'System Notification'),
    ]
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=100)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES)
    related_order = models.ForeignKey(Order, on_delete=models.SET_NULL, null=True, blank=True)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-created_at']