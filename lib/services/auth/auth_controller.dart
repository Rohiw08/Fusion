// lib/features/auth/controller/auth_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/core/utils/show_snackbar.dart';
import 'package:fusion/models/user_model.dart';
import 'package:fusion/services/auth/auth_repository.dart';

// Provider to hold the current user's data (UserModel)
final userProvider = StateProvider<UserModel?>((ref) => null);

// Main AuthController provider
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
      authRepository: ref.watch(authRepositoryProvider), ref: ref),
);

// Stream provider for the raw Firebase Auth state (User?)
final authStateProvider = StreamProvider<User?>(
  (ref) {
    // Depend on authControllerProvider to ensure it's initialized
    final authController = ref.watch(authControllerProvider.notifier);
    return authController.authState;
  },
);

// Stream provider to get specific user data (UserModel) based on UID
final getUserdataProvider =
    StreamProvider.family<UserModel, String>((ref, String uid) {
  // Depend on authControllerProvider to ensure it's initialized
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false) {
    // Initial state is not loading
    // Listen to Firebase auth state changes and update userProvider
    _authRepository.authState.listen((User? user) {
      if (user != null) {
        // If user is logged in, fetch their UserModel data
        _authRepository.getUserData(user.uid).first.then((userModel) {
          _ref.read(userProvider.notifier).update((state) => userModel);
        }).catchError((e) {
          // Handle error fetching user data if necessary
          print("Error fetching user data on auth change: $e");
          _ref
              .read(userProvider.notifier)
              .update((state) => null); // Clear user data on error
        });
      } else {
        // If user is logged out, clear the userProvider
        _ref.read(userProvider.notifier).update((state) => null);
      }
    });
  }

  Stream<User?> get authState => _authRepository.authState;

  // --- Modified createAccountWithGoogle ---
  void createAccountWithGoogle(
    BuildContext context, {
    required String email,
    required String password,
    // Removed name, address, contactNumber
  }) async {
    state = true; // Indicate loading started
    final userResult = await _authRepository.createAccountWithGoogle(
      email, password, // Pass only email and password
    );
    state = false; // Indicate loading finished

    userResult.fold(
        (error) =>
            showSnackBar(context, error.message), // Show error on failure
        (userModel) {
      // Update the userProvider with the new user data on success
      _ref.read(userProvider.notifier).update((state) => userModel);
      // Optional: Navigate to HomeScreen or show success message
      showSnackBar(context, 'Account created successfully!');
    });
  }

  // --- Modified logInWithGoogle ---
  void logInWithGoogle(BuildContext context,
      {required String email, required String password}) async {
    state = true;
    final userResult = await _authRepository.logInWithGoogle(email, password);
    state = false;

    userResult.fold((error) => showSnackBar(context, error.message),
        // Corrected fold for success: Directly update userProvider
        (userModel) {
      _ref.read(userProvider.notifier).update((state) => userModel);
      // Optional: Navigate to HomeScreen or show success message
      // Note: Navigation often happens automatically by watching authStateProvider
    });
  }

  // --- sendPasswordResetEmail (Unchanged) ---
  void sendPasswordResetEmail(BuildContext context,
      {required String email}) async {
    state = true;
    final result = await _authRepository.sendPasswordResetEmail(email: email);
    state = false;
    result.fold(
      (error) => showSnackBar(context, error.message),
      (successMessage) =>
          showSnackBar(context, successMessage), // Show success message
    );
  }

  // --- signOut (Added state management) ---
  void signOut(BuildContext context) async {
    // Added context for potential snackbar
    state = true;
    final result = await _authRepository.signOut();
    state = false;
    result.fold(
        (error) => showSnackBar(
            context, error.message), // Show error if sign out fails
        (_) {
      // Clear user provider explicitly (though authState listener also does this)
      _ref.read(userProvider.notifier).update((state) => null);
      // Optional: show success message or navigate (often handled by authStateProvider)
    });
  }

  // --- getUserData (Unchanged) ---
  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
