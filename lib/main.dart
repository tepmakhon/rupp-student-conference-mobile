import 'package:flutter/material.dart';
// import 'features/splash/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
void main() {
  runApp(const RUPPConferenceApp());
}

class RUPPConferenceApp extends StatelessWidget {
  const RUPPConferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RUPP Student Conference',
      home: const LoginScreen(),
    );
  }
}