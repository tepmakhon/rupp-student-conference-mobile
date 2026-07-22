import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/textfields/app_text_field.dart';
import '../../../core/widgets/texts/app_title.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

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
                subtitle: "Continue your learning journey",
              ),

              const SizedBox(height: 45),

              AppTextField(
                controller: emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              AppTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock_outline,
                obscureText: true,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text("Forgot Password?"),
                ),
              ),

              const SizedBox(height: 18),

              PrimaryButton(
                text: state.status == AuthStatus.loading
                    ? "Loading..."
                    : "Continue",
                onPressed: () {
                  if (state.status == AuthStatus.loading) return;
                  ref
                      .read(authProvider.notifier)
                      .login(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                },
              ),

              if (state.status == AuthStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    state.error ?? "Login failed",
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?",
                    style: TextStyle(color: Colors.grey),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
