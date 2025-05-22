from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from services.models import Service
from accounts.models import User
import json

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