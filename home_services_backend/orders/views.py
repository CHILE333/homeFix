from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from orders.models import Order, Payment
from accounts.models import User
from services.models import Service
import json

# ...existing code...

@csrf_exempt
def create_order(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        customer_id = data.get('customer_id')
        service_id = data.get('service_id')
        scheduled_date = data.get('scheduled_date')
        notes = data.get('notes', '')

        print(f"Processing order - service_id: {service_id}, customer_id: {customer_id}")

        try:
            customer = User.objects.get(id=customer_id)
            service = Service.objects.get(id=service_id)
            
            # Debug information
            print(f"Service found: {service.title}")
            print(f"Provider ID: {service.provider.id}")
            print(f"Provider username: {service.provider.username}")
            print(f"Is provider flag: {service.provider.is_provider}")

            order = Order.objects.create(
                customer=customer,
                service=service,
                scheduled_date=scheduled_date,
                notes=notes
            )
            
            # Create notification for the service provider
            from notifications.views import create_notification
            notification = create_notification(
                user_id=service.provider.id,
                title='New Service Booking',
                message=f'You have a new booking for {service.title} on {scheduled_date}',
                notification_type='new_order',
                related_order_id=order.id
            )
            
            if notification:
                print(f"Notification created successfully with ID: {notification.id}")
            else:
                print("Failed to create notification")

            return JsonResponse({'success': True, 'order_id': order.id})
        except User.DoesNotExist:
            print(f"Error: User {customer_id} not found")
            return JsonResponse({'success': False, 'message': 'User not found'})
        except Service.DoesNotExist:
            print(f"Error: Service {service_id} not found") 
            return JsonResponse({'success': False, 'message': 'Service not found'})
        except Exception as e:
            print(f"Error creating order: {str(e)}")
            return JsonResponse({'success': False, 'message': str(e)})

            
@csrf_exempt
def track_orders(request, user_id):
    if request.method == 'GET':
        orders = Order.objects.filter(customer_id=user_id)
        data = []
        for order in orders:
            data.append({
                'order_id': order.id,
                'service': order.service.title,
                'status': order.status,
                'scheduled_date': str(order.scheduled_date),
                'notes': order.notes
            })
        return JsonResponse({'orders': data})
