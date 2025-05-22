import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewScreen extends StatefulWidget {
  final String serviceName;
  final int? serviceId;

  const ViewScreen({super.key, required this.serviceName, this.serviceId});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _serviceDetails;

  // Replace with your Django backend URL
  static const String baseUrl = 'http://localhost:8000/services';

  @override
  void initState() {
    super.initState();
    _fetchServiceDetails();
  }

  Future<void> _fetchServiceDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // If we have a specific serviceId, use it for the API call
      if (widget.serviceId != null) {
        final response = await http.get(
          Uri.parse('$baseUrl/detail/${widget.serviceId}/'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);

          setState(() {
            _serviceDetails = data;
            _isLoading = false;
          });
          return;
        } else {
          setState(() {
            _error =
                'Failed to load service details. Status: ${response.statusCode}';
            _isLoading = false;
          });
          return;
        }
      }

      // If no serviceId, try to search by name
      final searchResponse = await http.get(
        Uri.parse('$baseUrl/list/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (searchResponse.statusCode == 200) {
        final data = json.decode(searchResponse.body);
        final List<dynamic> services = data['services'];

        // Find service by name
        final matchingService = services.firstWhere(
          (service) =>
              service['title'].toString().toLowerCase() ==
              widget.serviceName.toLowerCase(),
          orElse: () => null,
        );

        if (matchingService != null) {
          // We found the service, now get full details if possible
          if (matchingService['id'] != null) {
            final detailResponse = await http.get(
              Uri.parse('$baseUrl/detail/${matchingService['id']}/'),
              headers: {'Content-Type': 'application/json'},
            );

            if (detailResponse.statusCode == 200) {
              setState(() {
                _serviceDetails = json.decode(detailResponse.body);
                _isLoading = false;
              });
              return;
            }
          }

          // Fallback to using the list data
          setState(() {
            _serviceDetails = {
              'id': matchingService['id'],
              'title': matchingService['title'],
              'description': matchingService['description'],
              'category': matchingService['category'],
              'price': matchingService['price'],
              'rating': matchingService['rating'] ?? 0.0,
              'provider_id': matchingService['provider_id'],
              'provider_name': 'Service Provider',
              'available': true,
              'features': [],
            };
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Service not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error =
              'Failed to load services. Status: ${searchResponse.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  String _getCategoryImage(String? category) {
    if (category == null) return 'assets/services/default.png';

    switch (category.toLowerCase()) {
      case 'plumbing':
        return 'assets/services/plumbing.png';
      case 'electrical':
        return 'assets/services/electricity.png';
      case 'cleaning':
        return 'assets/services/cleaning.png';
      default:
        return 'assets/services/default.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildErrorWidget()
              : _buildServiceDetailView(),
      bottomNavigationBar:
          _isLoading || _error != null ? null : _buildBottomButtons(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.red[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchServiceDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailView() {
    final service = _serviceDetails!;
    final serviceName = service['title'] ?? widget.serviceName;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Hero Image
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey[200]),
            child:
                service['image'] != null
                    ? Image.network(
                      service['image'],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Image.asset(
                            _getCategoryImage(service['category']),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => Center(
                                  child: Icon(
                                    Icons.home_repair_service,
                                    size: 80,
                                    color: Colors.grey[400],
                                  ),
                                ),
                          ),
                    )
                    : Image.asset(
                      _getCategoryImage(service['category']),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.home_repair_service,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                          ),
                    ),
          ),

          // Service Title and Rating
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (service['category'] ?? 'General')
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if ((service['rating'] ?? 0) > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  service['rating'].toString(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${service['price']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Estimated time: ${service['duration'] ?? '1-2 hours'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Provider Info
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.business, color: Colors.white),
            ),
            title: Text(service['provider_name'] ?? 'Service Provider'),
            subtitle: const Text('Service Provider'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    (service['available'] ?? true)
                        ? Colors.green[100]
                        : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                (service['available'] ?? true) ? 'Available' : 'Unavailable',
                style: TextStyle(
                  fontSize: 12,
                  color:
                      (service['available'] ?? true)
                          ? Colors.green[800]
                          : Colors.red[800],
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Description
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  service['description'] ?? 'No description available',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),

          // Features
          if (service['features'] != null &&
              (service['features'] as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What\'s Included',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    (service['features'] as List).length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service['features'][index].toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Additional Information
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Additional Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Available 7 days a week'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.verified_user, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Satisfaction guaranteed'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_shipping, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Free transportation to service location'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 80,
          ), // Extra space at bottom for the bottom bar
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Message Button
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () {
                // Implement message functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message feature not implemented yet'),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Colors.blueAccent),
              ),
              child: const Text('Ask Questions'),
            ),
          ),
          const SizedBox(width: 16),
          // Book/Buy Button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // Implement booking/purchase functionality
                showModalBottomSheet(
                  context: context,
                  builder:
                      (context) => _buildBookingSheet(context, (
                        selectedDate,
                        selectedTime,
                      ) {
                        _createBooking(selectedDate, selectedTime);
                      }),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Book this Service'),
            ),
          ),
        ],
      ),
    );
  }

  // Add the missing _createBooking method
  void _createBooking(DateTime selectedDate, TimeOfDay selectedTime) {
    // You can implement your booking logic here, such as sending data to your backend.
    // For now, just show a confirmation message.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Booking confirmed for ${selectedDate.toLocal().toString().split(' ')[0]} at ${selectedTime.format(context)}!',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
} // End of _ViewScreenState class

// Booking sheet widget should be outside the state class and receive a callback
Widget _buildBookingSheet(
  BuildContext context,
  void Function(DateTime, TimeOfDay) onConfirm,
) {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  return StatefulBuilder(
    builder: (context, setState) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schedule Service',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select preferred date and time:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // Date picker
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Time picker
            InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  setState(() {
                    selectedTime = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Notes field
            TextField(
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Additional Notes',
                border: OutlineInputBorder(),
                hintText: 'Any specific requirements?',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onConfirm(selectedDate, selectedTime);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
// ...existing code...