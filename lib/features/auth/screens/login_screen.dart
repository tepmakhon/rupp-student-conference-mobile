import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/textfields/app_text_field.dart';
import '../../../core/widgets/texts/app_title.dart';

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

              const Icon(
                Icons.school_rounded,
                size: 90,
                color: AppColors.primary,
              ),

              const SizedBox(height: 30),

              const AppTitle(
                title: "Welcome Back",
                subtitle:
                    "Continue your learning journey",
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
                obscureText: true,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},

                  child: const Text(
                    "Forgot Password?",
                  ),
                ),
              ),

              const SizedBox(height: 18),

              PrimaryButton(
                text: "Continue",
                onPressed: () {},
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,

                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},

                    child: const Text(
                      "Create Account",

                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}