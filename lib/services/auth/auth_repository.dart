// lib/features/auth/repository/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fusion/core/constants/firebase_constants.dart';
import 'package:fusion/core/failure.dart';
import 'package:fusion/core/provider/auth_providers.dart';
import 'package:fusion/core/typedef.dart';
import 'package:fusion/models/user_model.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    auth: ref.read(firebaseAuthProvider),
    firebaseFirestore: ref.read(firebaseFirestoreProvider),
  ),
);

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firebaseFirestore;

  AuthRepository(
      {required FirebaseAuth auth,
      required FirebaseFirestore firebaseFirestore})
      : _auth = auth,
        _firebaseFirestore = firebaseFirestore;

  CollectionReference get _users =>
      _firebaseFirestore.collection(FirebaseConstants.userCollection);

  // --- Modified createAccountWithGoogle ---
  FutureEither<UserModel> createAccountWithGoogle(
      String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw "Email and Password cannot be empty.";
      }
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw "User creation failed unexpectedly.";
      }
      // Use empty strings for fields not collected at sign-up
      final userdata = UserModel(
          name: "",
          contactNumber: "",
          address: "",
          uid: user.uid,
          email: email);

      await _users.doc(user.uid).set(userdata.toMap());
      return right(userdata);
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "An unknown Firebase error occurred."));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // --- logInWithGoogle (Unchanged) ---
  FutureEither<UserModel> logInWithGoogle(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;
      if (user == null) {
        throw "Login failed unexpectedly.";
      }
      final userModel = await getUserData(user.uid).first;
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(Failure(
          e.message ?? "An unknown Firebase error occurred during login."));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // --- sendPasswordResetEmail (Unchanged) ---
  FutureEither<String> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return right("Password reset email sent successfully");
    } on FirebaseException catch (e) {
      return left(Failure(e.message ?? "Failed to send password reset email."));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // --- signOut (Unchanged) ---
  FutureVoid signOut() async {
    try {
      await _auth.signOut();
      return right(unit);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // --- authState (Unchanged) ---
  Stream<User?> get authState => _auth.authStateChanges();

  // --- getUserData (Unchanged, added error handling for non-existent doc) ---
  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map((event) {
      if (!event.exists || event.data() == null) {
        // Return a default/empty model or throw, depending on desired behavior
        print("Warning: User document for UID $uid does not exist.");
        // Returning a default empty model to prevent stream error
        return UserModel(
            name: '', contactNumber: '', address: '', uid: uid, email: '');
        // OR: throw Exception("User data not found for UID: $uid");
      }
      return UserModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }
}
