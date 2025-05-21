import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  // Form Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // State Observables
  final isLoading = false.obs;
  final isLoggedIn = false.obs;
  final currentUser = Rxn<Map<String, dynamic>>();
  final errorMessage = ''.obs;

  @override
  void onInit() {
    checkAuthState();
    super.onInit();
  }

  Future<void> checkAuthState() async {
    try {
      isLoading.value = true;
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        isLoggedIn.value = true;
        await fetchUserData(session.user.id);
      }
    } catch (e) {
      errorMessage.value = 'Error checking auth state: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserData(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      currentUser.value = response;
    } catch (e) {
      errorMessage.value = 'Failed to fetch user data: ${e.toString()}';
    }
  }

  Future<void> register() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Validate passwords match
      if (passwordController.text != confirmPasswordController.text) {
        throw Exception('Passwords do not match');
      }

      // Create auth user
      final authResponse = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        throw Exception('Registration failed');
      }

      // Save user profile
      await Supabase.instance.client.from('users').upsert({
        'id': authResponse.user!.id,
        'email': emailController.text.trim(),
        'full_name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update state
      isLoggedIn.value = true;
      await fetchUserData(authResponse.user!.id);
      Get.offAllNamed('/home');
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      isLoggedIn.value = true;
      await fetchUserData(response.user!.id);
      Get.offAllNamed('/home');
    } on AuthException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      isLoggedIn.value = false;
      currentUser.value = null;
      clearControllers();
      Get.offAllNamed('/login');
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    nameController.clear();
    phoneController.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}