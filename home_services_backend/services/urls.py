from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_service, name='create_service'),
    path('list/', views.list_services, name='list_services'),
    path('providers/', views.get_providers_by_service, name='get_providers_by_service'),
    path('detail/<int:service_id>/', views.get_service_detail, name='get_service_detail'),
    path('book/', views.book_service, name='book_service'),
    path('update/<int:service_id>/', views.update_service, name='update_service'),
    path('delete/<int:service_id>/', views.delete_service, name='delete_service'),
    path('provider/<int:provider_id>/', views.provider_services, name='provider_services'),
]