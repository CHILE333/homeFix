from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from services.models import Service
from accounts.models import User
import json
from orders.models import Order

@csrf_exempt
def create_service(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        title = data.get('title')
        description = data.get('description')
        category = data.get('category')
        price = data.get('price')
        provider_id = data.get('provider_id')

        try:
            provider = User.objects.get(id=provider_id, is_provider=True)
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Invalid provider'})

        service = Service.objects.create(
            title=title,
            description=description,
            category=category,
            price=price,
            provider=provider
        )

        return JsonResponse({'success': True, 'service_id': service.id})

@csrf_exempt
def list_services(request):
    if request.method == 'GET':
        services = Service.objects.all()
        data = []
        for service in services:
            data.append({
                'id': service.id,
                'title': service.title,
                'description': service.description,
                'category': service.category,
                'price': str(service.price),
                'provider_id': service.provider.id,
                'rating': service.rating
            })
        return JsonResponse({'services': data})


@csrf_exempt
def get_providers_by_service(request):
    if request.method == 'GET':
        try:
            service_name = request.GET.get('service')
            if not service_name:
                return JsonResponse({'success': False, 'message': 'Service name is required'}, status=400)
                
            # First try to find the service category for this service name
            try:
                service = Service.objects.filter(title__icontains=service_name).first()
                if service:
                    service_category = service.category
                else:
                    # Fallback to using the service name as category
                    service_category = service_name
            except Exception:
                service_category = service_name
                
            # Get providers who offer services in the given category
            providers = User.objects.filter(
                service__category__iexact=service_category,
                is_provider=True
            ).distinct()
            
            providers_data = []
            
            for provider in providers:
                # Get profile data - adjust this based on your actual Profile model
                profile_picture = None
                phone = None
                location = None
                
                try:
                    # Assuming you have a Profile model
                    profile = Profile.objects.get(user=provider)
                    profile_picture = profile.profile_picture.url if profile.profile_picture else None
                    phone = profile.phone
                    location = profile.address
                except:
                    pass
                
                # Get service count
                service_count = Service.objects.filter(provider=provider).count()
                
                # Get average rating
                avg_rating = service_count / 10 + 3.5  # Placeholder formula
                if avg_rating > 5:
                    avg_rating = 5.0
                
                providers_data.append({
                    'id': provider.id,
                    'name': provider.username,
                    'photo': profile_picture or 'assets/profiles/default.png',
                    'phone': phone or 'Not available',
                    'email': provider.email,
                    'location': location or 'Not specified',
                    'rating': round(avg_rating, 1),
                    'experience': f"{1 + service_count//5} years",  # Placeholder formula
                    'price': round(50 + service_count * 2, 2),      # Placeholder formula
                    'availability': 'Available',
                })
            
            return JsonResponse({'success': True, 'providers': providers_data})
        
        except Exception as e:
            return JsonResponse({
                'success': False, 
                'message': f'Error fetching providers: {str(e)}'
            }, status=500)


@csrf_exempt
def get_service_detail(request, service_id):
    if request.method == 'GET':
        try:
            service = Service.objects.get(id=service_id)
            
            # Get the provider info
            provider = service.provider
            provider_name = provider.get_full_name() or provider.username
            
            # You can expand this with additional service details
            features = [
                f"Professional {service.category} service",
                "Quality guarantee",
                "Experienced professionals",
                "Tools and equipment included",
            ]
            
            data = {
                'id': service.id,
                'title': service.title,
                'description': service.description,
                'category': service.category,
                'price': str(service.price),
                'rating': service.rating,
                'duration': '1-2 hours',  # You might want to add this to your model
                'provider_id': provider.id,
                'provider_name': provider_name,
                'available': True,
                'features': features,
                # Add image URL if available
                'image': service.image.url if service.image else None,
            }
            
            return JsonResponse(data)
        except Service.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Service not found'}, status=404)
        except Exception as e:
            return JsonResponse({
                'success': False, 
                'message': f'Error fetching service details: {str(e)}'
            }, status=500)


@csrf_exempt
def book_service(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            customer_id = data.get('customer_id')
            service_id = data.get('service_id')
            scheduled_date = data.get('scheduled_date')
            scheduled_time = data.get('scheduled_time')
            notes = data.get('notes', '')
            
            # Create order
            customer = User.objects.get(id=customer_id)
            service = Service.objects.get(id=service_id)
            
            order = Order.objects.create(
                customer=customer,
                service=service,
                scheduled_date=scheduled_date,
                notes=notes
            )
            
            # Create notification for the service provider
            from notifications.views import create_notification
            provider_notification = create_notification(
                user_id=service.provider.id,
                title='New Service Booking',
                message=f'You have a new booking for {service.title} on {scheduled_date} at {scheduled_time}',
                notification_type='new_order',
                related_order_id=order.id
            )
            
            # Create notification for the customer as well
            customer_notification = create_notification(
                user_id=customer_id,
                title='Booking Confirmed',
                message=f'Your booking for {service.title} has been confirmed for {scheduled_date} at {scheduled_time}',
                notification_type='order_status',
                related_order_id=order.id
            )
            
            return JsonResponse({
                'success': True, 
                'order_id': order.id,
                'message': 'Service booked successfully'
            })
            
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'User not found'})
        except Service.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Service not found'})
        except Exception as e:
            return JsonResponse({'success': False, 'message': str(e)})


@csrf_exempt
def update_service(request, service_id):
    if request.method == 'PUT':
        try:
            data = json.loads(request.body)
            provider_id = data.get('provider_id')
            
            # Get the service and verify ownership
            service = Service.objects.get(id=service_id)
            if service.provider.id != provider_id:
                return JsonResponse({'success': False, 'message': 'Not authorized to update this service'}, status=403)
            
            # Update the service fields
            if 'title' in data:
                service.title = data['title']
            if 'description' in data:
                service.description = data['description']
            if 'category' in data:
                service.category = data['category']
            if 'price' in data:
                service.price = data['price']
            if 'is_active' in data:
                service.is_active = data['is_active']
                
            service.save()
            
            return JsonResponse({'success': True, 'message': 'Service updated successfully'})
            
        except Service.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Service not found'}, status=404)
        except Exception as e:
            return JsonResponse({'success': False, 'message': str(e)}, status=500)

@csrf_exempt
def delete_service(request, service_id):
    if request.method == 'DELETE':
        try:
            data = json.loads(request.body)
            provider_id = data.get('provider_id')
            
            # Get the service and verify ownership
            service = Service.objects.get(id=service_id)
            if service.provider.id != provider_id:
                return JsonResponse({'success': False, 'message': 'Not authorized to delete this service'}, status=403)
            
            # Check if this service has active orders
            active_orders = Order.objects.filter(service=service, status__in=['pending', 'confirmed']).exists()
            if active_orders:
                return JsonResponse({
                    'success': False, 
                    'message': 'Cannot delete service with active orders'
                }, status=400)
                
            service.delete()
            return JsonResponse({'success': True, 'message': 'Service deleted successfully'})
            
        except Service.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Service not found'}, status=404)
        except Exception as e:
            return JsonResponse({'success': False, 'message': str(e)}, status=500)


@csrf_exempt
def provider_services(request, provider_id):
    if request.method == 'GET':
        try:
            # Verify the provider exists
            provider = User.objects.get(id=provider_id, is_provider=True)
            
            # Get all services provided by this user
            services = Service.objects.filter(provider=provider)
            
            data = []
            for service in services:
                # Get the count of active orders for this service
                active_orders = Order.objects.filter(
                    service=service, 
                    status__in=['pending', 'confirmed']
                ).count()
                
                data.append({
                    'id': service.id,
                    'title': service.title,
                    'description': service.description,
                    'category': service.category,
                    'price': str(service.price),
                    'rating': service.rating,
                    'is_active': service.is_active,
                    'created_at': service.created_at.strftime('%Y-%m-%d %H:%M:%S'),
                    'active_orders': active_orders
                })
                
            return JsonResponse({'success': True, 'services': data})
            
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Provider not found'}, status=404)
        except Exception as e:
            return JsonResponse({'success': False, 'message': str(e)}, status=500)