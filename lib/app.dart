import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RUPP Student Conference",

      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,

      home: const Scaffold(
        body: Center(
          child: Text(
            "RUPP Student Conference Platform",
          ),
        ),
      ),
    );
  }
}