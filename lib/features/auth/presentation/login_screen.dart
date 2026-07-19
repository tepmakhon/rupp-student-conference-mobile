import 'package:flutter/material.dart';

import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/constants/app_colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),

          child: Column(
            children: [
              const SizedBox(height: 70),

              const AppLogo(),

              const SizedBox(height: 30),

              const Text(
                "Welcome Back",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Continue your learning journey",
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 45),

              const AppTextField(
                label: "Email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              const AppTextField(
                label: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 15),

              PrimaryButton(
                text: "Continue",
                onPressed: () {
                  // TODO: Login
                },
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      // TODO: Navigate Register
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}