// lib/features/auth/view/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/CustomWidgets/auth_widgets.dart';
import 'package:fusion/CustomWidgets/custom_button.dart';
import 'package:fusion/CustomWidgets/password_text_field.dart';
import 'package:fusion/Screens/password_reset_screen.dart';
import 'package:fusion/Screens/signup_screen.dart';
import 'package:fusion/core/utils/show_snackbar.dart';
import 'package:fusion/services/auth/auth_controller.dart';

// --- LoginScreen Widget (Use code from previous response) ---
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void logInUser({required String email, required String password}) {
    if (email.isEmpty || password.isEmpty) {
      showSnackBar(context,
          "Please enter both email and password."); // Use showSnackBar util
      return;
    }
    ref
        .read(authControllerProvider.notifier)
        .logInWithGoogle(context, email: email, password: password);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider); // Watch loading state
    return Scaffold(
      /* ... Same build method as before ... */
      body: SafeArea(
        child: Center(
          // Center the content vertically and horizontally
          child: SingleChildScrollView(
            // Allow scrolling on smaller screens
            padding: const EdgeInsets.all(25.0), // Padding around the content
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center column content
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally too
              children: [
                const Icon(Icons.storefront, size: 100, color: Colors.grey),
                const SizedBox(height: 30), // Spacing after logo

                // Welcome Text
                const Text(
                  "Welcome Back!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Login to continue",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 35),

                // Email Field
                MyTextField(
                  controller: _emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(height: 15),

                // Password Field
                PasswordTextField(
                  controller: _passwordController,
                  hintText: "Password",
                ),
                const SizedBox(height: 20),

                // Forgot Password & Register Links
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const PasswordResetScreen())),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const SignUpScreen())),
                        child: Text(
                          "Register Now",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: MyButton(
                    buttonText: "Login",
                    onTap: () => logInUser(
                        email: _emailController.text.trim(),
                        password: _passwordController.text),
                    isLoading: isLoading, // Use loading state
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
