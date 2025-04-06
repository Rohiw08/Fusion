// lib/features/auth/view/password_reset_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/CustomWidgets/auth_widgets.dart';
import 'package:fusion/core/utils/show_snackbar.dart';
import 'package:fusion/services/auth/auth_controller.dart';

class PasswordResetScreen extends ConsumerStatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  ConsumerState<PasswordResetScreen> createState() =>
      _PasswordResetScreenState();
}

class _PasswordResetScreenState extends ConsumerState<PasswordResetScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void sendResetEmail() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showSnackBar(context, "Please enter your email address.");
      return;
    }
    ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(context, email: email);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider); // Watch loading state

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter your email address to receive a password reset link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            MyTextField(
              controller: _emailController,
              hintText: "Email Address",
              obscureText: false,
            ),
            const SizedBox(height: 30),
            MyButton(
              buttonText: "Send Reset Link",
              onTap: sendResetEmail,
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
