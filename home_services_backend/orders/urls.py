from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_order, name='create_order'),
    path('track/<int:user_id>/', views.track_orders, name='track_orders'),
]

