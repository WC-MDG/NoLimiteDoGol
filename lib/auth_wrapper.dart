// lib/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';


// Import your HomeScreen from its new location
import 'home_screen.dart'; // Make sure this path is correct

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) 
        {// User is not logged in, show the SignInScreen
          return SignInScreen
          (
            providers: 
            [
              EmailAuthProvider(), // Enables Email/Password sign-in
              GoogleProvider
              (
                clientId: '80764980308-hotmujr30jf4lbjfg7qo8ba7k9bsiln0.apps.googleusercontent.com', // Your Client ID!
              ), // Enables Google Sign-In
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  // You can add your app logo here if you have one, e.g., Image.asset('assets/my_app_logo.png')
                  child: Icon(Icons.lock, size: 100), // Placeholder icon
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to NoLimiteDoGol! Please sign in.')
                    : const Text('Join the NoLimiteDoGol community!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              );
            },
            actions: [
              AuthStateChangeAction<SignedIn>((context, state) {
                // This action runs when a user successfully signs in.
                // The StreamBuilder will automatically rebuild and show HomeScreen.
                if (state.user != null) {
                  print('User ${state.user!.email} signed in!');
                }
              }),
            ],
          );
        }

        // User is logged in, show the main application content
        return const HomeScreen();
      },
    );
  }
}
