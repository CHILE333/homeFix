import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'viewScreen.dart';

class HomeServiceScreen extends StatefulWidget {
  const HomeServiceScreen({super.key});
  @override
  State<HomeServiceScreen> createState() => _HomeServiceScreenState();
}

class _HomeServiceScreenState extends State<HomeServiceScreen> {
  String? _selectedService;
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  String? _error;

  // Replace with your Django backend URL
  static const String baseUrl = 'http://localhost:8000/services';
  // For local development, use: 'http://10.0.2.2:8000/api/services' for Android emulator
  // or 'http://localhost:8000/api/services' for iOS simulator

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response = await http.get(
        Uri.parse('$baseUrl/list/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> servicesData = data['services'];

        setState(() {
          _services =
              servicesData
                  .map(
                    (service) => {
                      'id': service['id'],
                      'name': service['title'],
                      'description': service['description'],
                      'category': service['category'],
                      'price': service['price'],
                      'provider_id': service['provider_id'],
                      'rating': service['rating'],
                      'image': _getServiceImage(service['category']),
                    },
                  )
                  .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load services. Status: ${response.statusCode}';
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

  String _getServiceImage(String category) {
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

  List<Map<String, dynamic>> get _filteredServices {
    final q = _searchController.text.toLowerCase();
    return _services.where((s) {
      final matchSearch =
          q.isEmpty ||
          s['name'].toString().toLowerCase().contains(q) ||
          s['description'].toString().toLowerCase().contains(q) ||
          s['category'].toString().toLowerCase().contains(q);
      final matchSelected =
          _selectedService == null || s['category'] == _selectedService;
      return matchSearch && matchSelected;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Services'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchServices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Category Filter
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip(null, 'All'),
                _buildCategoryChip('plumbing', 'Plumbing'),
                _buildCategoryChip('electrical', 'Electrical'),
                _buildCategoryChip('cleaning', 'Cleaning'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Services List
          Expanded(child: _buildServicesList()),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String? category, String label) {
    final isSelected = _selectedService == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedService = selected ? category : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildServicesList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
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
              onPressed: _fetchServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredServices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No services found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        final service = _filteredServices[index];
        return _buildServiceCard(service);
      },
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ViewScreen(
                    // service: service,
                    serviceName: service['name'],
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Service Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    service['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.build,
                        size: 30,
                        color: Colors.grey[400],
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Service Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          service['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${service['price']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      service['description'],
                      style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                            service['category'].toString().toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),

                        const Spacer(),

                        if (service['rating'] > 0)
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
