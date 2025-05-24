from django.urls import path
from . import views

urlpatterns = [
    path('notification/<int:user_id>/', views.get_notifications, name='get_notifications'),
    path('mark-read/<int:notification_id>/', views.mark_notification_read, name='mark_notification_read'),
]