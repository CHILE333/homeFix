import 'package:flutter/material.dart';
import 'package:homefix/views/splash.dart'; // Import SplashScreen

void main() {
  runApp(const HomeFixApp());
}

class HomeFixApp extends StatelessWidget {
  const HomeFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), 
    );
  }
}