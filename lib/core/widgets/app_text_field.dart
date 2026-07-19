import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;

  const AppTextField({
    super.key,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,

      obscureText: obscure,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            width: 2,
          ),
        ),
      ),
    );
  }
}