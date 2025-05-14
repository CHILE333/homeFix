import 'package:flutter/material.dart';

class ViewScreen extends StatefulWidget {
  final String serviceName; // Service clicked (e.g., "Plumbing")

  const ViewScreen({super.key, required this.serviceName});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  String _sortOption = 'Rating'; // Default sort option

  // Service-specific providers with unique names and varied star ratings
  final Map<String, List<Map<String, dynamic>>> _serviceProviders = {
    'Plumbing': [
      {
        'name': 'Alan Carter',
        'image': 'assets/providers/alan_carter.png',
        'services': 10,
        'accuracy': 97,
        'rating': 4.5,
        'description': 'Skilled plumber specializing in leak repairs and pipe installations.',
      },
      {
        'name': 'Sophie Hayes',
        'image': 'assets/providers/sophie_hayes.png',
        'services': 7,
        'accuracy': 94,
        'rating': 4.0,
        'description': 'Reliable plumber for drain cleaning and fixture maintenance.',
      },
      {
        'name': 'David Lee',
        'image': 'assets/providers/david_lee.png',
        'services': 14,
        'accuracy': 98,
        'rating': 4.8,
        'description': 'Certified plumber with extensive experience in plumbing solutions.',
      },
    ],
    'Electricity': [
      {
        'name': 'Brian Foster',
        'image': 'assets/providers/brian_foster.png',
        'services': 12,
        'accuracy': 96,
        'rating': 4.3,
        'description': 'Expert electrician for wiring and lighting installations.',
      },
      {
        'name': 'Clara Evans',
        'image': 'assets/providers/clara_evans.png',
        'services': 9,
        'accuracy': 93,
        'rating': 3.8,
        'description': 'Professional electrician specializing in circuit repairs.',
      },
      {
        'name': 'Ethan Moore',
        'image': 'assets/providers/ethan_moore.png',
        'services': 16,
        'accuracy': 99,
        'rating': 4.7,
        'description': 'Highly rated electrician for comprehensive electrical services.',
      },
    ],
    'Painting': [
      {
        'name': 'Fiona Clark',
        'image': 'assets/providers/fiona_clark.png',
        'services': 8,
        'accuracy': 95,
        'rating': 4.2,
        'description': 'Creative painter for interior and exterior projects.',
      },
      {
        'name': 'George Adams',
        'image': 'assets/providers/george_adams.png',
        'services': 11,
        'accuracy': 92,
        'rating': 3.9,
        'description': 'Detail-oriented painter specializing in wall repairs.',
      },
      {
        'name': 'Hannah Brooks',
        'image': 'assets/providers/hannah_brooks.png',
        'services': 13,
        'accuracy': 97,
        'rating': 4.6,
        'description': 'Experienced painter delivering high-quality finishes.',
      },
    ],
    'Toilet Unblocking': [
      {
        'name': 'Ian Wright',
        'image': 'assets/providers/ian_wright.png',
        'services': 9,
        'accuracy': 94,
        'rating': 4.1,
        'description': 'Efficient specialist in clog removal and pipe cleaning.',
      },
      {
        'name': 'Julia Stone',
        'image': 'assets/providers/julia_stone.png',
        'services': 6,
        'accuracy': 91,
        'rating': 3.7,
        'description': 'Dedicated professional for toilet unblocking services.',
      },
      {
        'name': 'Kevin Patel',
        'image': 'assets/providers/kevin_patel.png',
        'services': 12,
        'accuracy': 96,
        'rating': 4.4,
        'description': 'Trusted expert in resolving complex plumbing blockages.',
      },
    ],
    'Gardening': [
      {
        'name': 'Laura Green',
        'image': 'assets/providers/laura_green.png',
        'services': 10,
        'accuracy': 95,
        'rating': 4.3,
        'description': 'Passionate gardener for lawn care and landscaping.',
      },
      {
        'name': 'Mark Taylor',
        'image': 'assets/providers/mark_taylor.png',
        'services': 7,
        'accuracy': 93,
        'rating': 3.8,
        'description': 'Skilled in hedge trimming and garden maintenance.',
      },
      {
        'name': 'Nina Scott',
        'image': 'assets/providers/nina_scott.png',
        'services': 15,
        'accuracy': 98,
        'rating': 4.7,
        'description': 'Expert gardener creating beautiful outdoor spaces.',
      },
    ],
    'Window Cleaning': [
      {
        'name': 'Oliver King',
        'image': 'assets/providers/oliver_king.png',
        'services': 8,
        'accuracy': 94,
        'rating': 4.0,
        'description': 'Professional window cleaner for sparkling results.',
      },
      {
        'name': 'Paula Reed',
        'image': 'assets/providers/paula_reed.png',
        'services': 6,
        'accuracy': 92,
        'rating': 3.6,
        'description': 'Reliable cleaner for interior and exterior windows.',
      },
      {
        'name': 'Quentin Hall',
        'image': 'assets/providers/quentin_hall.png',
        'services': 11,
        'accuracy': 97,
        'rating': 4.5,
        'description': 'Top-rated window cleaner with attention to detail.',
      },
    ],
    'Furniture Repair': [
      {
        'name': 'Rachel Ward',
        'image': 'assets/providers/rachel_ward.png',
        'services': 9,
        'accuracy': 95,
        'rating': 4.2,
        'description': 'Expert in wood repair and furniture restoration.',
      },
      {
        'name': 'Samuel Cole',
        'image': 'assets/providers/samuel_cole.png',
        'services': 7,
        'accuracy': 93,
        'rating': 3.9,
        'description': 'Skilled craftsman for upholstery and furniture fixes.',
      },
      {
        'name': 'Tara Young',
        'image': 'assets/providers/tara_young.png',
        'services': 12,
        'accuracy': 96,
        'rating': 4.6,
        'description': 'Highly rated specialist in furniture repair.',
      },
    ],
  };

  // Get providers for the selected service
  List<Map<String, dynamic>> get _sortedProviders {
    final providers = List<Map<String, dynamic>>.from(
      _serviceProviders[widget.serviceName] ?? [],
    );
    if (_sortOption == 'Rating') {
      providers.sort((a, b) => b['rating'].compareTo(a['rating']));
    } else if (_sortOption == 'Experience') {
      providers.sort((a, b) => b['services'].compareTo(a['services']));
    } else if (_sortOption == 'Accuracy') {
      providers.sort((a, b) => b['accuracy'].compareTo(a['accuracy']));
    }
    return providers;
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
        ),
        title: const Text(
          'Select Your Provider',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Logo and Title
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 60,
                    width: 60,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.home_repair_service,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Select Your ${widget.serviceName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sorting Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort By:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueAccent,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortOption,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort, color: Colors.blueAccent),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    items: ['Rating', 'Experience', 'Accuracy']
                        .map((option) => DropdownMenuItem(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _sortOption = value!;
                      });
                    },
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                  ),
                ],
              ),
            ),

            // Providers List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.serviceName} Providers',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sortedProviders.isEmpty
                      ? const Center(
                          child: Text(
                            'No providers available for this service.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _sortedProviders.length,
                          itemBuilder: (context, index) {
                            final provider = _sortedProviders[index];
                            return ProviderCard(provider: provider);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Provider Card Widget
class ProviderCard extends StatelessWidget {
  final Map<String, dynamic> provider;

  const ProviderCard({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${provider['name']} profile...')),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      provider['image'],
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Provider Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          provider['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Metrics
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMetricChip(
                              icon: Icons.build,
                              label: '${provider['services']}+ Services',
                              isLowerOverflow: provider['services'] < 10,
                            ),
                            _buildMetricChip(
                              icon: Icons.check_circle,
                              label: '${provider['accuracy']}% Accuracy',
                              isLowerOverflow: provider['accuracy'] < 95,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Star Rating
                        Row(
                          children: List.generate(5, (index) {
                            double rating = provider['rating'];
                            if (index < rating.floor()) {
                              return const Icon(Icons.star, color: Colors.amber, size: 20);
                            } else if (index < rating) {
                              return const Icon(Icons.star_half, color: Colors.amber, size: 20);
                            } else {
                              return const Icon(Icons.star_border, color: Colors.amber, size: 20);
                            }
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          provider['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Booking ${provider['name']}...')),
                                );
                              },
                              child: const Text(
                                'Book Now',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blueAccent,
                                side: const BorderSide(color: Colors.blueAccent, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Viewing ${provider['name']} profile...')),
                                );
                              },
                              child: const Text(
                                'View Profile',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
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
        ),
      ),
    );
  }

  // Helper widget for metric chips
  Widget _buildMetricChip({required IconData icon, required String label, required bool isLowerOverflow}) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isLowerOverflow ? 110 : 100, // Adjust for lower overflow cases
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blueAccent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}