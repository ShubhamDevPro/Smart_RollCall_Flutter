import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services/auth_service.dart';
import 'auth_page.dart';


class HomePage extends StatelessWidget {
  HomePage({super.key});

  // Get the current user from Firebase Auth
  final user = FirebaseAuth.instance.currentUser;

  // Update AuthService usage
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Display user's name
            Text(
              user?.displayName ?? "Welcome!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Display user's email
            Text(
              "You've successfully logged in with:",
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              user?.email ?? "N/A",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 40),
            // Logout button
            ElevatedButton(
              onPressed: () async {
                if (await _authService.signOut()) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AuthPage()),
                  );
                }
              },
              child: Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
