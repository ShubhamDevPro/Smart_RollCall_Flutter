import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';

// AuthPage handles the authentication state and decides which page to show
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Listen to authentication state changes
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If user is authenticated, show HomePage
          if (snapshot.hasData) {
            return HomePage();
          } else {
            // If user is not authenticated, show LoginPage
            return LoginPage();
          }
        },
      ),
    );
  }
}
