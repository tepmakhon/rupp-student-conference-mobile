import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class AppTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,

          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          subtitle,

          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}