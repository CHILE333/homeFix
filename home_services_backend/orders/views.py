from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from services.models import Service
from accounts.models import User
from orders.models import Order  # Add this import
import json


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
            # Get provider and their profile information
            provider = order.service.provider
            provider_name = f"{provider.first_name} {provider.last_name}" if provider.first_name else provider.username
            
            # Access provider's profile for phone and address
            try:
                from accounts.models import Profile
                provider_profile = Profile.objects.get(user=provider)
                provider_phone = provider_profile.phone
                provider_address = provider_profile.address
            except Exception:
                # Fallback if no profile exists
                provider_phone = "N/A"
                provider_address = "N/A"
            
            data.append({
                'order_id': order.id,
                'service': order.service.title,
                'provider_name': provider_name,
                'provider_phone': provider_phone,  # Updated to use profile
                'provider_address': provider_address,  # Updated to use profile
                'status': order.status,
                'scheduled_date': str(order.scheduled_date),
                'notes': order.notes,
                'location': {'lat': 0.0, 'lng': 0.0}  # Add dummy coordinates or actual provider location
            })
        return JsonResponse({'orders': data})


@csrf_exempt
def order_detail(request, order_id):
    """API endpoint to get detailed information about an order"""
    try:
        order = Order.objects.get(id=order_id)
        
        # Format provider name
        provider = order.service.provider
        provider_name = f"{provider.first_name} {provider.last_name}" if provider.first_name else provider.username
        
        # Format customer name
        customer = order.customer
        customer_name = f"{customer.first_name} {customer.last_name}" if customer.first_name else customer.username
        
        # Get additional details from related models if needed
        data = {
            'id': order.id,
            'service_id': order.service.id,
            'service_title': order.service.title,
            'provider_id': provider.id,
            'provider_name': provider_name,
            'customer_id': customer.id,
            'customer_name': customer_name,
            'status': order.status,
            'scheduled_date': order.scheduled_date.isoformat() if order.scheduled_date else None,
            'scheduled_time': order.scheduled_time if hasattr(order, 'scheduled_time') else None,
            'date_ordered': order.date_ordered.isoformat(),
            'notes': order.notes,
            'price': str(order.service.price)
        }
        
        return JsonResponse(data)
    except Order.DoesNotExist:
        return JsonResponse({'success': False, 'message': 'Order not found'}, status=404)
    except Exception as e:
        return JsonResponse({'success': False, 'message': str(e)}, status=500)

@csrf_exempt
def update_order_status(request, order_id):
    """API endpoint to update order status"""
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            new_status = data.get('status')
            
            if new_status not in [status[0] for status in Order.STATUS_CHOICES]:
                return JsonResponse({
                    'success': False, 
                    'message': 'Invalid status'
                }, status=400)
            
            order = Order.objects.get(id=order_id)
            order.status = new_status
            order.save()
            
            # Create notifications for both customer and provider
            from notifications.views import create_notification
            
            # Notify customer
            customer_message = f"Your order for {order.service.title} has been {new_status}"
            create_notification(
                user_id=order.customer.id,
                title=f"Order {new_status.capitalize()}",
                message=customer_message,
                notification_type='order_status',
                related_order_id=order.id
            )
            
            # Notify provider (unless they're the one updating)
            if request.user.id != order.service.provider.id:
                provider_message = f"Order #{order.id} for {order.service.title} has been {new_status}"
                create_notification(
                    user_id=order.service.provider.id,
                    title=f"Order {new_status.capitalize()}",
                    message=provider_message,
                    notification_type='order_status',
                    related_order_id=order.id
                )
            
            return JsonResponse({'success': True, 'status': new_status})
        except Order.DoesNotExist:
            return JsonResponse({'success': False, 'message': 'Order not found'}, status=404)
        except Exception as e:
            return JsonResponse({'success': False, 'message': str(e)}, status=500)
    else:
        return JsonResponse({'success': False, 'message': 'Method not allowed'}, status=405)