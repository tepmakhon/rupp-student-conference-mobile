import 'package:flutter/material.dart';

import '../../../core/storage/token_storage.dart';

class SplashController {
  static Future<void> initialize(
    BuildContext context,
  ) async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    final token = await TokenStorage.getToken();

    if (!context.mounted) return;

    if (token != null) {
      Navigator.pushReplacementNamed(
        context,
        "/dashboard",
      );
    } else {
      Navigator.pushReplacementNamed(
        context,
        "/login",
      );
    }
  }
}