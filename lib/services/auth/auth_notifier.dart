// lib/features/auth/controller/auth_notifier.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fusion/services/auth/auth_controller.dart';

// Provider for the AuthNotifier
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends ChangeNotifier {
  final Ref _ref;
  late final StreamSubscription<User?> _authStateSubscription;
  User? _user; // Holds the current Firebase User object

  AuthNotifier(this._ref) {
    // Listen to the authStateProvider (which streams Firebase User?)
    _authStateSubscription =
        _ref.read(authStateProvider.stream).listen(_onAuthStateChanged);
    // Initialize with current user synchronously if possible (for initial redirect)
    _user = _ref.read(firebaseAuthProvider).currentUser; // Corrected dependency
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  void _onAuthStateChanged(User? user) {
    if (_user != user) {
      _user = user;
      notifyListeners(); // Notify GoRouter's refreshListenable
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel(); // Cancel subscription on dispose
    super.dispose();
  }
}

// Helper provider to get the firebase auth instance
// (You might already have this defined elsewhere, e.g., firebase_provider.dart)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
