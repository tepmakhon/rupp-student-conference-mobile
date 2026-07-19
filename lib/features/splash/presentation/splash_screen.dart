import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      // TODO: Navigate to Login Screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school_rounded,
                size: 90,
                color: Color(0xFF0F4C3A),
              ),

              SizedBox(height: 24),

              Text(
                "RUPP Student Conference",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F4C3A),
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Conference • Scholarship • Internship",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              SizedBox(height: 40),

              CircularProgressIndicator(
                color: Color(0xFFD4AF37),
              ),
            ],
          ),
        ),
      ),
    );
  }
}