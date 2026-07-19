import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final IconData icon;

  final bool obscureText;

  final TextEditingController? controller;

  const AppTextField({
    super.key,

    required this.label,

    required this.icon,

    this.obscureText = false,

    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      obscureText: obscureText,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(16),
        ),
      ),
    );
  }
}