from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import get_user_model
from accounts.models import Profile, User
import json
from django.contrib.auth import authenticate

User = get_user_model()

@csrf_exempt
def register_user(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')
        email = data.get('email')
        is_provider = data.get('is_provider', False)
        phone = data.get('phone')
        address = data.get('address')

        if User.objects.filter(username=username).exists():
            return JsonResponse({'success': False, 'message': 'Username already taken'})

        user = User.objects.create_user(username=username, password=password, email=email, is_provider=is_provider)
        Profile.objects.create(user=user, phone=phone, address=address)

        return JsonResponse({'success': True, 'user_id': user.id})


@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        user = authenticate(username=data['username'], password=data['password'])
        if user:
            return JsonResponse({'success': True, 'user_id': user.id, 'is_provider': user.is_provider})
        else:
            return JsonResponse({'success': False, 'message': 'Invalid credentials'})


@csrf_exempt
def get_profile(request, user_id):
    if request.method == 'GET':
        try:
            user = User.objects.get(id=user_id)
            profile = user.profile
            return JsonResponse({
                'success': True,
                'username': user.username,
                'email': user.email,
                'phone': profile.phone,
                'address': profile.address,
                'is_provider': user.is_provider
            })
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'User not found'})

@csrf_exempt
def update_profile(request, user_id):
    if request.method == 'POST':
        try:
            user = User.objects.get(id=user_id)
            profile = user.profile
            data = json.loads(request.body)

            user.email = data.get('email', user.email)
            profile.phone = data.get('phone', profile.phone)
            profile.address = data.get('address', profile.address)
            user.save()
            profile.save()

            return JsonResponse({'success': True, 'message': 'Profile updated successfully'})
        except User.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'User not found'})
