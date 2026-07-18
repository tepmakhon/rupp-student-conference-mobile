import 'package:flutter/material.dart';

void main() {
  runApp(const RuppConferenceApp());
}

class RuppConferenceApp extends StatelessWidget {
  const RuppConferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RUPP Student Conference',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'RUPP Student Conference',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}