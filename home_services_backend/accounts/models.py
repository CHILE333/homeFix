from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    is_provider = models.BooleanField(default=False)
    is_admin = models.BooleanField(default=False)

class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    phone = models.CharField(max_length=15)
    address = models.TextField()
    profile_picture = models.ImageField(upload_to='profiles/', null=True, blank=True)
