// lib/features/auth/widgets/auth_widgets.dart
import 'package:flutter/material.dart';

// --- Placeholder Widget Implementations (Copied from previous responses) ---
// MyTextField, PasswordTextField, MyButton implementations go here...

class MyTextField extends StatelessWidget {
  /* ... Full implementation ... */
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 0), // Adjusted padding if needed
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: hintText,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  /* ... Full implementation ... */
  final TextEditingController controller;
  final String hintText;
  const PasswordTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });
  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  /* ... Full implementation with toggle ... */
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 0), // Adjusted padding if needed
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),
          hintText: widget.hintText,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  /* ... Full implementation ... */
  final String buttonText;
  final VoidCallback onTap;
  final bool isLoading;
  const MyButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.isLoading = false,
  });
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ))
            : Text(buttonText),
      ),
    );
  }
}
