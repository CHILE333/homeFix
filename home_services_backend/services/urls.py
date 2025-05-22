from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_service, name='create_service'),
    path('list/', views.list_services, name='list_services'),
    path('providers/', views.get_providers_by_service, name='get_providers_by_service'),
    path('detail/<int:service_id>/', views.get_service_detail, name='get_service_detail'),
]
