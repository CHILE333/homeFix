import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Replace with actual user ID - this should come from authentication
      final int userId = 1;

      final response = await http.get(
        Uri.parse('http://localhost:8000/notifications/$userId/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _notifications.clear();
          _notifications.addAll(
            List<Map<String, dynamic>>.from(data['notifications']),
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await http.post(
        Uri.parse(
          'http://localhost:8000/notifications/mark-read/$notificationId/',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Update the local state
        setState(() {
          final notification = _notifications.firstWhere(
            (n) => n['id'] == notificationId,
            orElse: () => {},
          );
          if (notification.isNotEmpty) {
            notification['is_read'] = true;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking notification as read: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(_error!, style: TextStyle(color: Colors.red[700])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchNotifications,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : RefreshIndicator(
                onRefresh: _fetchNotifications,
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder:
                      (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationTile(notification);
                  },
                ),
              ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> notification) {
    final DateTime createdAt = DateTime.parse(notification['created_at']);
    final bool isRead = notification['is_read'] ?? false;
    final String formattedDate = DateFormat(
      'MMM d, yyyy • h:mm a',
    ).format(createdAt);

    IconData iconData;
    Color iconColor;

    switch (notification['notification_type']) {
      case 'new_order':
        iconData = Icons.shopping_cart;
        iconColor = Colors.blue;
        break;
      case 'order_status':
        iconData = Icons.update;
        iconColor = Colors.green;
        break;
      case 'message':
        iconData = Icons.message;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.purple;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(iconData, color: iconColor),
      ),
      title: Text(
        notification['title'],
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(notification['message']),
          const SizedBox(height: 4),
          Text(
            formattedDate,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        // If not read, mark as read
        if (!isRead) {
          _markAsRead(notification['id']);
        }

        // Show notification details or navigate to related content
        if (notification['related_order_id'] != null) {
          // Navigate to order details
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Navigating to order details...')),
          );
        } else {
          // Show notification details
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(notification['title']),
                  content: Text(notification['message']),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
          );
        }
      },
      tileColor: isRead ? null : Colors.blue.withOpacity(0.05),
    );
  }
}
