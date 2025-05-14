import 'package:flutter/material.dart';
import 'view.dart'; // Import ViewScreen for navigation

class HomeServiceScreen extends StatefulWidget {
  const HomeServiceScreen({super.key});

  @override
  State<HomeServiceScreen> createState() => _HomeServiceScreenState();
}

class _HomeServiceScreenState extends State<HomeServiceScreen> {
  String? _selectedService;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Plumbing',
      'image': 'assets/services/plumbing.png',
      'description': 'Fix leaks, install fixtures, drain cleaning',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Electricity',
      'image': 'assets/services/electricity.png',
      'description': 'Wiring, outlets, circuit breakers, lighting',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Painting',
      'image': 'assets/services/painting.png',
      'description': 'Interior/exterior painting, wall repairs',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Toilet Unblocking',
      'image': 'assets/services/toilet.png',
      'description': 'Clog removal, pipe cleaning',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Gardening',
      'image': 'assets/services/gardening.png',
      'description': 'Lawn mowing, hedge trimming',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Window Cleaning',
      'image': 'assets/services/windows.png',
      'description': 'Interior/exterior window washing',
      'category': 'Home Services Partners'
    },
    {
      'name': 'Furniture Repair',
      'image': 'assets/services/furniture.png',
      'description': 'Wood repair, upholstery',
      'category': 'Home Services Partners'
    },
  ];

  List<Map<String, dynamic>> get _filteredServices {
    final query = _searchController.text.toLowerCase();
    return _services.where((service) {
      final matchesSearch = query.isEmpty || service['name'].toLowerCase().contains(query) || service['description'].toLowerCase().contains(query);
      final matchesCategory = _selectedService == null || _selectedService == 'All Services' || service['name'] == _selectedService;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back to Home',
        ),
        title: const Text(
          'HomeFix Services',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          semanticsLabel: 'HomeFix Services',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
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
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/homefix_banner.png',
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.2),
                          colorBlendMode: BlendMode.darken,
                          errorBuilder: (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blueAccent, Colors.blue.shade700],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Fix Your Home with Ease',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              semanticsLabel: 'Fix Your Home with Ease',
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Certified contractors at your fingertips',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search services...',
                          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  tooltip: 'Clear search',
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown for Home Services Partners
                    TweenAnimationBuilder(
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
                      child: DropdownButtonFormField<String>(
                        value: _selectedService,
                        hint: const Text(
                          'Home Services Partners',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.blueAccent,
                          size: 30,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                          prefixIcon: const Icon(
                            Icons.home_repair_service,
                            color: Colors.blueAccent,
                            size: 24,
                          ),
                        ),
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        items: ['All Services', ..._services.map((service) => service['name'] as String)].map((service) {
                          return DropdownMenuItem<String>(
                            value: service,
                            child: Row(
                              children: [
                                Icon(
                                  _getServiceIcon(service),
                                  color: Colors.blueAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  service,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedService = newValue;
                          });
                        },
                        menuMaxHeight: 300,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(16),
                        validator: (value) => null, // Optional validation
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Services List Header
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1400),
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
                        'Available Services',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        semanticsLabel: 'Available Services',
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Services List
                    _filteredServices.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No services found.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        : AnimatedListView(
                            services: _filteredServices,
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

  // Helper method to assign icons to services
  IconData _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electricity':
        return Icons.electrical_services;
      case 'Painting':
        return Icons.format_paint;
      case 'Toilet Unblocking':
        return Icons.bathroom;
      case 'Gardening':
        return Icons.grass;
      case 'Window Cleaning':
         return Icons.window;
      case 'Furniture Repair':
        return Icons.chair;
      case 'All Services':
        return Icons.build;
      default:
        return Icons.build;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Custom Animated ListView for Services
class AnimatedListView extends StatelessWidget {
  final List<Map<String, dynamic>> services;

  const AnimatedListView({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 500 + (index * 100)),
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewScreen(serviceName: service['name']),
                ),
              );
            },
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.blue.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Image on Left
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      child: Image.asset(
                        service['image'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      ),
                    ),

                    // Service Info and Button
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service Name
                            Text(
                              service['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                              semanticsLabel: service['name'],
                            ),
                            const SizedBox(height: 8),

                            // Service Description
                            Text(
                              service['description'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),

                            // Book Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  elevation: 2,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ViewScreen(serviceName: service['name']),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Book Now',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  semanticsLabel: 'Book Now',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}