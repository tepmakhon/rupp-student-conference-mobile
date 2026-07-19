import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
// import 'features/splash/pages/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RUPP Student Conference",

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const LoginScreen(),
    );
  }
}