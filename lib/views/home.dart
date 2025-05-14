import 'package:flutter/material.dart';
import 'home_service.dart'; // Ensure this file exists in the project
import 'register_service.dart'; // Ensure this file exists
import 'track_your_order.dart'; // Ensure this file exists
import 'make_payment.dart'; // Ensure this file exists

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
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
                  const SizedBox(height: 8),
                  const Text(
                    'HomeFix',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blueAccent),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About page coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.blueAccent),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Support page coming soon!')),
                );
              },
            ),
          ],
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Logo and Title
                const SizedBox(height: 40),
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
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 100,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.home_repair_service,
                          size: 100,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const Text(
                        'HomeFix',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        semanticsLabel: 'HomeFix',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.blueAccent),
                          onPressed: () {
                            try {
                              Scaffold.of(context).openDrawer();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error opening drawer: $e')),
                              );
                            }
                          },
                          tooltip: 'Open menu',
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search for services...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            onChanged: (value) {
                              // Placeholder for search functionality
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.account_circle, color: Colors.blueAccent),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile page coming soon!')),
                            );
                          },
                          tooltip: 'View profile',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Four Action Buttons
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
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildActionButton(
                        icon: Icons.home_repair_service,
                        label: 'Home Service',
                        onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeServiceScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error navigating to Home Service: $e')),
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.app_registration,
                        label: 'Register Service',
                        onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterServiceScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error navigating to Register Service: $e')),
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.track_changes,
                        label: 'Track Your Order',
                        onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TrackYourOrderScreen(),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error navigating to Track Your Order: $e')),
                            );
                          }
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.payment,
                        label: 'Make Payment',
                        onPressed: () {
                          try {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MakePaymentScreen(
                                  serviceName: 'Sample Service',
                                  providerName: 'Sample Provider',
                                  amount: 50.0,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error navigating to Make Payment: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Follow Us Section
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
                  child: Column(
                    children: [
                      const Text(
                        'Follow Us',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        semanticsLabel: 'Follow Us',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSocialIcon(context, 'assets/images/facebook_logo.png', 'Facebook'),
                          const SizedBox(width: 20),
                          _buildSocialIcon(context, 'assets/images/instagram_logo.png', 'Instagram'),
                          const SizedBox(width: 20),
                          _buildSocialIcon(context, 'assets/images/twitter_logo.png', 'Twitter'),
                          const SizedBox(width: 20),
                          _buildSocialIcon(context, 'assets/images/whatsapp_logo.png', 'WhatsApp'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        elevation: 4,
        shadowColor: Colors.blueAccent.withOpacity(0.3),
      ),
      onPressed: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, String imagePath, String platform) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$platform link coming soon!')),
          );
        },
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.broken_image,
            size: 40,
            color: Colors.grey.shade400,
          ),
          semanticLabel: platform,
        ),
      ),
    );
  }
}