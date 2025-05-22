from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register_user, name='register_user'),
    path('login/', views.login_view, name='login'),
    path('profile/<int:user_id>/', views.get_profile, name='get_profile'),
    path('profile/<int:user_id>/update/', views.update_profile, name='update_profile'),
]