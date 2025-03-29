import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/bottom_nav.dart';
import 'package:ku_report_app/screens/user/forgot_password.dart';
import 'package:ku_report_app/screens/user/signin.dart';
import 'package:ku_report_app/screens/user/signup.dart';
import 'package:ku_report_app/theme/color.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KU Reporting App',
      theme: ThemeData(primarySwatch: customGreenPrimary),
      home: AuthWrapper(),
      routes: {
        '/sign-in': (context) => SignInPage(),
        '/home': (context) => BottomNavBar(role: 'User'), // define the '/home' route
        '/sign-up': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in => sign in
      return SignInPage();
    } else {
      // User is already logged in, so let's print their email
      print('Current user email: ${user.email}');

      // Now proceed to check Firestore for the user's role
      return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
  // For example, sign out then show a simple screen:
  FirebaseAuth.instance.signOut();

  return Scaffold(
    body: Center(
      child: Text('No user record found. Please sign up.'),
    ),
  );
}

          final role = snapshot.data!['role'] as String? ?? 'User';
          return BottomNavBar(role: role);
        },
      );
    }
  }
}
