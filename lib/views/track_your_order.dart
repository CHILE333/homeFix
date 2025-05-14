import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrackYourOrderScreen extends StatefulWidget {
  const TrackYourOrderScreen({super.key});

  @override
  State<TrackYourOrderScreen> createState() => _TrackYourOrderScreenState();
}

class _TrackYourOrderScreenState extends State<TrackYourOrderScreen> {
  // Sample order data (replace with API call in production)
  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD001',
      'service': 'Plumbing',
      'provider': 'Davis Victor',
      'address': 'Plot 45, Mikocheni, Dar es Salaam, Tanzania',
      'phone': '+255712345678',
      'status': 'In Progress',
      'location': {'lat': -6.7689, 'lng': 39.2396},
    },
    {
      'id': 'ORD002',
      'service': 'Electricity',
      'provider': 'David Byamungu',
      'address': 'Kariakoo Market, Dar es Salaam, Tanzania',
      'phone': '+255674789852',
      'status': 'Requested',
      'location': {'lat': -6.8191, 'lng': 39.2743},
    },
    {
      'id': 'ORD003',
      'service': 'Painting',
      'provider': 'Senga Senga',
      'address': 'Mbezi Beach, Dar es Salaam, Tanzania',
      'phone': '+255686569580',
      'status': 'Completed',
      'location': {'lat': -6.7332, 'lng': 39.2257},
    },
    {
      'id': 'ORD004',
      'service': 'Gardening',
      'provider': 'Li Wei',
      'address': 'Upanga, Dar es Salaam, Tanzania',
      'phone': '+255765432109',
      'status': 'In Progress',
      'location': {'lat': -6.8135, 'lng': 39.2876},
    },
    {
      'id': 'ORD005',
      'service': 'Window Cleaning',
      'provider': 'Zhang Min',
      'address': 'Oyster Bay, Dar es Salaam, Tanzania',
      'phone': '+255789123456',
      'status': 'Requested',
      'location': {'lat': -6.7631, 'lng': 39.2765},
    },
  ];

  int _visibleOrders = 3; // Initially show 3 orders

  void _loadMoreOrders() {
    setState(() {
      _visibleOrders = (_visibleOrders + 2).clamp(0, _orders.length);
    });
  }

  void _showMapDialog(Map<String, dynamic> location) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/images/map_placeholder.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.map, size: 80, color: Colors.blueAccent),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Provider Location (Lat: ${location['lat']}, Lng: ${location['lng']})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _contactProvider(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to make a call')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: Semantics(
          label: 'Back to Home',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Back',
          ),
        ),
        title: const Text(
          'Track Your Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          semanticsLabel: 'Track Your Orders',
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: const Text(
                    'Your Orders',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                    semanticsLabel: 'Your Orders',
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _visibleOrders,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 1000 + index * 200),
                      curve: Curves.easeInOut,
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${order['id']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  _buildStatusBadge(order['status']),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Service: ${order['service']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Provider: ${order['provider']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Address: ${order['address']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'Contact: ${order['phone']}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.map),
                                    label: const Text('View Map'),
                                    onPressed: () => _showMapDialog(order['location']),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.phone),
                                    label: const Text('Contact'),
                                    onPressed: () => _contactProvider(order['phone']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (_visibleOrders < _orders.length)
                  Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 50 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        ),
                        onPressed: _loadMoreOrders,
                        child: const Text(
                          'View More Orders',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Requested':
        color = Colors.orange;
        break;
      case 'In Progress':
        color = Colors.blue;
        break;
      case 'Completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}