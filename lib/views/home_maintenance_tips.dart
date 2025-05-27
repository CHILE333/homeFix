// home_maintenance_tips.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeMaintenanceTips extends StatefulWidget {
  const HomeMaintenanceTips({super.key});

  @override
  State<HomeMaintenanceTips> createState() => _HomeMaintenanceTipsState();
}

class _HomeMaintenanceTipsState extends State<HomeMaintenanceTips> {
  final List<MaintenanceTip> _allTips = [];
  List<MaintenanceTip> _filteredTips = [];
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _favorites = {};
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  void _loadTips() {
    _allTips.addAll([
      MaintenanceTip(
        id: '1',
        title: "Clean AC Filters",
        category: "HVAC",
        difficulty: 1,
        time: "5 mins",
        steps: [
          "Turn off AC unit",
          "Locate filter panel (usually behind return air vent)",
          "Remove and inspect filter",
          "Vacuum loose debris or rinse with water",
          "Let dry completely before reinstalling"
        ],
        seasonal: "Summer",
        emergency: false,
        icon: Icons.ac_unit,
        color: Colors.blue.shade100,
        imagePath: 'assets/images/ac_filter.jpeg',
      ),
      MaintenanceTip(
        id: '2',
        title: "Prevent Frozen Pipes",
        category: "Plumbing",
        difficulty: 2,
        time: "15 mins",
        steps: [
          "Locate vulnerable pipes (attics, basements, exterior walls)",
          "Wrap pipes with insulation sleeves",
          "Keep cabinet doors open to allow warm air circulation",
          "Let faucets drip during extreme cold"
        ],
        seasonal: "Winter",
        emergency: false,
        icon: Icons.water_damage,
        color: Colors.lightBlue.shade100,
        imagePath: 'assets/images/frozen_pipes.jpeg',
      ),
      MaintenanceTip(
        id: '3',
        title: "Test Smoke Detectors",
        category: "Electrical",
        difficulty: 1,
        time: "10 mins",
        steps: [
          "Press and hold the test button on each detector",
          "Listen for loud alarm sound",
          "Replace batteries if needed",
          "Vacuum detector to remove dust",
          "Test monthly for best safety"
        ],
        seasonal: null,
        emergency: false,
        icon: Icons.sensors,
        color: Colors.red.shade100,
        imagePath: 'assets/images/smoke_detector.jpeg',
      ),
      MaintenanceTip(
        id: '4',
        title: "Clean Gutters",
        category: "Exterior",
        difficulty: 3,
        time: "1-2 hours",
        steps: [
          "Use sturdy ladder with stabilizer",
          "Wear gloves and safety glasses",
          "Remove leaves and debris by hand",
          "Flush with garden hose",
          "Check for proper drainage"
        ],
        seasonal: "Fall",
        emergency: false,
        icon: Icons.house,
        color: Colors.green.shade100,
        imagePath: 'assets/images/gutters.jpeg',
      ),
      MaintenanceTip(
        id: '5',
        title: "Check Fire Extinguisher",
        category: "Safety",
        difficulty: 1,
        time: "5 mins",
        steps: [
          "Verify pressure gauge is in green zone",
          "Inspect for physical damage",
          "Check pull-pin and tamper seal",
          "Shake dry chemical extinguishers monthly",
          "Replace if over 12 years old"
        ],
        seasonal: null,
        emergency: false,
        icon: Icons.local_fire_department,
        color: Colors.orange.shade100,
        imagePath: 'assets/images/fire_extinguisher.jpeg',
      ),
      MaintenanceTip(
        id: '6',
        title: "Water Heater Flush",
        category: "Plumbing",
        difficulty: 2,
        time: "30 mins",
        steps: [
          "Turn off power/gas to heater",
          "Attach hose to drain valve",
          "Open pressure relief valve",
          "Drain several gallons until water runs clear",
          "Close valves and restore power"
        ],
        seasonal: "Spring",
        emergency: false,
        icon: Icons.electric_bolt,
        color: Colors.blue.shade100,
        imagePath: 'assets/images/water_heater.jpeg',
      ),
    ]);
    _filteredTips = _allTips;
  }

  void _toggleFavorite(String id) {
    setState(() {
      _favorites[id] = !(_favorites[id] ?? false);
    });
  }

  void _filterTips(String query) {
    setState(() {
      _filteredTips = _allTips.where((tip) {
        final matchesSearch = tip.title.toLowerCase().contains(query.toLowerCase()) || 
                            tip.category.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || 
                              tip.category == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _filterTips(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/logo.png', 
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade800.withOpacity(0.7),
                          Colors.lightBlue.shade400.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Home Maintenance Tips',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Keep your home in perfect condition',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchBar(),
                const SizedBox(height: 20),
                _buildCategoriesGrid(),
                const SizedBox(height: 30),
                _buildSectionHeader('Featured Tips'),
                const SizedBox(height: 10),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildTipCard(_filteredTips[index]),
                childCount: _filteredTips.length,
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search tips...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.blue),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _filterTips('');
                    },
                  )
                : null,
          ),
          onChanged: _filterTips,
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }

  Widget _buildCategoriesGrid() {
    final categories = ['All', 'Seasonal', 'Plumbing', 'Electrical', 'HVAC', 'Exterior', 'Safety'];
    
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(categories[index]),
              selected: _selectedCategory == categories[index],
              onSelected: (bool selected) {
                _filterByCategory(categories[index]);
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade100,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                color: _selectedCategory == categories[index] 
                    ? Colors.blue.shade800 
                    : Colors.grey.shade800,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: _selectedCategory == categories[index]
                      ? Colors.blue.shade300
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedCategory = 'All';
              _searchController.clear();
              _filterTips('');
            });
          },
          child: const Text('Reset Filters'),
        ),
      ],
    );
  }

  Widget _buildTipCard(MaintenanceTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTipDetails(tip),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: tip.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tip.icon, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, 
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(tip.time, 
                                style: TextStyle(color: Colors.grey.shade600)),
                            const SizedBox(width: 12),
                            ...List.generate(
                              3,
                              (index) => Icon(
                                Icons.star,
                                size: 16,
                                color: index < tip.difficulty
                                    ? Colors.amber.shade600
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _favorites[tip.id] ?? false ? Icons.favorite : Icons.favorite_border,
                      color: (_favorites[tip.id] ?? false) ? Colors.red : Colors.grey,
                    ),
                    onPressed: () => _toggleFavorite(tip.id),
                  ),
                ],
              ),
              if (tip.seasonal != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Best in ${tip.seasonal}',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * _filteredTips.indexOf(tip)).ms);
  }

  void _showTipDetails(MaintenanceTip tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: tip.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(tip.icon, size: 28, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      tip.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _favorites[tip.id] ?? false 
                          ? Icons.favorite 
                          : Icons.favorite_border,
                      color: (_favorites[tip.id] ?? false) ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      _toggleFavorite(tip.id);
                      Navigator.pop(context);
                      _showTipDetails(tip);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (tip.imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    tip.imagePath!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                children: [
                  Chip(
                    label: Text(tip.category),
                    backgroundColor: Colors.blue.shade50,
                  ),
                  const SizedBox(width: 10),
                  Chip(
                    label: Text('${tip.difficulty}/3 Difficulty'),
                    backgroundColor: Colors.amber.shade50,
                  ),
                  const Spacer(),
                  Text(tip.time, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Steps:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: tip.steps.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip.steps[index],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.share),
                  label: const Text('Share This Tip'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Implement share functionality
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MaintenanceTip {
  final String id;
  final String title;
  final String category;
  final int difficulty;
  final String time;
  final List<String> steps;
  final String? seasonal;
  final bool emergency;
  final IconData icon;
  final Color color;
  final String? imagePath;

  MaintenanceTip({
    required this.id,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.time,
    required this.steps,
    this.seasonal,
    required this.emergency,
    required this.icon,
    required this.color,
    this.imagePath,
  });
}
