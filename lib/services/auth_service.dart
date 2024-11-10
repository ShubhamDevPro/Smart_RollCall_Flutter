import 'package:firebase_auth/firebase_auth.dart';

/// AuthService class handles authentication operations using Firebase Auth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Attempts to sign in the user with email and password
  /// Returns true if successful, false otherwise
  Future<bool> signInWithEmailPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  /// Registers a new user with email and password
  /// Returns true if successful, false otherwise
  Future<bool> registerWithEmailPassword(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Registration error: $e');
      return false;
    }
  }

  /// Signs out the current user from Firebase
  /// Returns true if successful, false otherwise
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      return true;
    } catch (e) {
      print('Sign out error: $e');
      return false;
    }
  }
}
