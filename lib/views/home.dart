// home_screen.dart
import 'package:flutter/material.dart';
import 'home_service.dart';
import 'register_service.dart';
import 'track_your_order.dart';
import 'home_maintenance_tips.dart'; // New import
import 'user_profile.dart';
import 'notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.blue.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          title: Row(
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  width: 40,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home_repair_service,
                          size: 24,
                          color: Colors.blueAccent,
                        ),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'HomeFix',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const NotificationsScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                tooltip: 'Notifications',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const ProfileScreen(),
                      transitionsBuilder: (_, animation, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: 0.8 + 0.2 * value,
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      width: 60,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.home_repair_service,
                            size: 60,
                            color: Colors.white,
                          ),
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
              title: const Text(
                'Home',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.account_circle,
                color: Colors.blueAccent,
              ),
              title: const Text(
                'Profile',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const ProfileScreen(),
                    transitionsBuilder: (_, animation, __, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blueAccent),
              title: const Text(
                'About',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('About page coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.support, color: Colors.blueAccent),
              title: const Text(
                'Support',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'What service do you need today?',
                      style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.blueAccent,
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality here
                  },
                ),
              ),
              const SizedBox(height: 40),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildServiceCard(
                    context,
                    icon: Icons.home_repair_service,
                    label: 'Home Service',
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeServiceScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.app_registration,
                    label: 'Register Service',
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final userId = prefs.getInt('user_id') ?? 0;
                      final isProvider = prefs.getBool('is_provider') ?? false;

                      if (!isProvider || userId == 0) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                              'Please log in as a service provider first',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ServiceRegistrationForm(
                            providerId: userId,
                            baseUrl: 'http://localhost:8000',
                          ),
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.track_changes,
                    label: 'Track Order',
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const TrackYourOrderScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 1),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    icon: Icons.handyman,
                    label: 'Maintenance Tips',
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const HomeMaintenanceTips(),
                          transitionsBuilder: (_, animation, __, child) {
                            return ScaleTransition(
                              scale: Tween<double>(
                                begin: 0.5,
                                end: 1.0,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.fastOutSlowIn,
                              )),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'Connect With Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          'assets/images/facebook_logo.png',
                          'Facebook',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Facebook page coming soon!'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          'assets/images/instagram_logo.png',
                          'Instagram',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Instagram page coming soon!'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          'assets/images/twitter_logo.png',
                          'Twitter',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Twitter page coming soon!'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        _buildSocialButton(
                          'assets/images/whatsapp_logo.png',
                          'WhatsApp',
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('WhatsApp coming soon!'),
                            ),
                          ),
                        ),
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
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: 0.8 + 0.2 * value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 30, color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 12),
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
      ),
    );
  }

  Widget _buildSocialButton(
    String imagePath,
    String platform,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: platform,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              imagePath,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.blueAccent),
            ),
          ),
        ),
      ),
    );
  }
}