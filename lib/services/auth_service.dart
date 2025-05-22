import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl =
      'http://localhost:8000'; // Change this to your actual URL
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _isProviderKey = 'is_provider';
  static const String _phoneKey = 'phone';
  static const String _addressKey = 'address';

  // Register new user
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String address,
    bool isProvider = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
          'phone': phone,
          'address': address,
          'is_provider': isProvider,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'user_id': data['user_id']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Add debug prints
      print('Debug - Login attempt for: $username');

      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      print('Debug - Response status: ${response.statusCode}');
      print('Debug - Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Convert to proper boolean if necessary
        // This handles cases where is_provider might be "true"/"false" strings or 0/1 integers
        bool isProvider = false;
        var providerValue = data['is_provider'];

        if (providerValue is bool) {
          isProvider = providerValue;
        } else if (providerValue is String) {
          isProvider = providerValue.toLowerCase() == 'true';
        } else if (providerValue is num) {
          isProvider = providerValue > 0;
        }

        print('Debug - User ID: ${data['user_id']}');
        print('Debug - Is Provider (parsed): $isProvider');
        print('Debug - Is Provider (original): ${data['is_provider']}');

        // Save user data with the properly converted boolean
        await _saveUserData(
          userId: data['user_id'],
          username: username,
          isProvider: isProvider,
        );

        // Fetch and save profile data
        await _fetchAndSaveProfile(data['user_id']);

        return {
          'success': true,
          'user_id': data['user_id'],
          'is_provider': isProvider,
        };
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      print('Debug - Login error: ${e.toString()}');
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accounts/profile/$userId/update/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'phone': phone, 'address': address}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_emailKey, email);
        await prefs.setString(_phoneKey, phone);
        await prefs.setString(_addressKey, address);

        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Update failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Save user data to local storage
  static Future<void> _saveUserData({
    required int userId,
    required String username,
    required bool isProvider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isProviderKey, isProvider);
  }

  // Fetch and save profile data
  static Future<void> _fetchAndSaveProfile(int userId) async {
    final profileData = await getProfile(userId);
    if (profileData['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emailKey, profileData['email'] ?? '');
      await prefs.setString(_phoneKey, profileData['phone'] ?? '');
      await prefs.setString(_addressKey, profileData['address'] ?? '');
    }
  }

  // Get user profile from backend
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/accounts/profile/$userId/'),
        headers: {'Content-Type': 'application/json'},
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'email': data['email'],
          'phone': data['phone'],
          'address': data['address'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Get current user data from local storage
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null) return null;

    return {
      'user_id': userId,
      'username': prefs.getString(_usernameKey) ?? '',
      'email': prefs.getString(_emailKey) ?? '',
      'phone': prefs.getString(_phoneKey) ?? '',
      'address': prefs.getString(_addressKey) ?? '',
      'is_provider': prefs.getBool(_isProviderKey) ?? false,
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey) != null;
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_isProviderKey);
  }
}
