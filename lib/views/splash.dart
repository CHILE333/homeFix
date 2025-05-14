import 'package:flutter/material.dart';
import 'package:homefix/views/home.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to Home after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // hapa unabadili background unaweza ukaweka yoyote ila kwakuwa app hii inatumia white and blue color so battr iwe blue 
      body: Center(
        child: Image.asset('assets/images/logo.png'), // Your logo 
      ),
    );
  }
}