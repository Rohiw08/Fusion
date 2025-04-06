// lib/features/auth/view/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Adjust import paths based on your actual project structure
import 'package:fusion/CustomWidgets/auth_widgets.dart'; // Assuming this path is correct
import 'package:fusion/core/utils/show_snackbar.dart'; // Assuming this path is correct
import 'package:fusion/services/auth/auth_controller.dart'; // Assuming this path is correct

// --- SignUpScreen Widget (Padding added to TextFields) ---
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});
  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // Only keep controllers for email and password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Updated createAccount function
  void createAccount({required String email, required String password}) {
    if (email.isEmpty || password.isEmpty) {
      showSnackBar(
          context, "Please fill in all fields."); // Use showSnackBar util
      return;
    }
    // Call the updated controller method
    ref.read(authControllerProvider.notifier).createAccountWithGoogle(
          context,
          email: email,
          password: password,
          // No name, address, contactNumber arguments
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider); // Watch loading state

    // Define the horizontal padding value
    const double horizontalPadding = 25.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              vertical: 20.0), // Existing vertical padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                child:
                    Icon(Icons.account_circle, size: 100, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                "Create Account",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // --- Add Padding around MyTextField ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: MyTextField(
                  controller: _emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
              ),
              const SizedBox(height: 15),

              // --- Add Padding around PasswordTextField ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: PasswordTextField(
                  controller: _passwordController,
                  hintText: "Password",
                ),
              ),
              const SizedBox(height: 35),

              // Button already has its own padding in the previous code
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: MyButton(
                  buttonText: "Register",
                  onTap: () => createAccount(
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                  ),
                  isLoading: isLoading, // Use loading state
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  // If not pushed (e.g., initial route), consider navigation logic
                  // else { context.go('/login'); } // Example using GoRouter if needed
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
