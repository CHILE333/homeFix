from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_order, name='create_order'),
    path('track/<int:user_id>/', views.track_orders, name='track_orders'),
    path('detail/<int:order_id>/', views.order_detail, name='order_detail'),
    path('update-status/<int:order_id>/', views.update_order_status, name='update_order_status'),
]