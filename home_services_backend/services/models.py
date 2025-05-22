from django.db import models
from accounts.models import User
from django.db.models.signals import post_save
from django.dispatch import receiver

class Service(models.Model):
    CATEGORY_CHOICES = [
        ('plumbing', 'Plumbing'),
        ('electrical', 'Electrical'),
        ('cleaning', 'Cleaning'),
        ('carpentry', 'Carpentry'),
        ('painting', 'Painting'),
        ('gardening', 'Gardening'),
        ('appliance', 'Appliance Repair'),
        ('other', 'Other'),
    ]
    
    title = models.CharField(max_length=100)
    description = models.TextField()
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    provider = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='provided_services',
        limit_choices_to={'is_provider': True}
    )
    image = models.ImageField(upload_to='services/', null=True, blank=True)
    rating = models.FloatField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"{self.title} by {self.provider.username}"
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Service'
        verbose_name_plural = 'Services'