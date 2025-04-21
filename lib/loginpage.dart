import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'registration_menu.dart'; // Import your page

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Google Login")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final user = await AuthService.signInWithGoogle();

              // Navigate to RegistrationMenu after login
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => RegistrationMenu()),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Login failed: $e")),
              );
            }
          },
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}
