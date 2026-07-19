import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.school_rounded,
      size: size,
      color: AppColors.primary,
    );
  }
}