// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Make sure this import is working
import 'controllers/auth_controller.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/home.dart';
import 'views/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HomeFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      getPages: [
        GetPage(name: '/', page: () => const AuthWrapper()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/register', page: () => const RegisterView()),
        GetPage(name: '/home', page: () => const HomeScreen()),
      ],
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());
    
    return Obx(() {
      if (authController.isLoading.value) {
        return const SplashScreen();
      }
      
      return authController.isLoggedIn.value 
          ? const HomeScreen() 
          : const LoginView();
    });
  }
}