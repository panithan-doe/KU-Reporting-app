import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/user/signin.dart';   // or wherever your SignInPage is located
import 'bottom_nav.dart';            // the role-based bottom nav

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    // If the user is NOT logged in, show sign in
    if (user == null) {
      return SignInPage();
    } else {
      // The user is logged in, so fetch their role from Firestore
      return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // If there's no record in Firestore for this user
            return const Scaffold(
              body: Center(
                child: Text('No user record found in Firestore.'),
              ),
            );
          }

          // The user's doc was found
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final role = (userData['role'] ?? 'User') as String;

          // Pass the role to the bottom nav
          return BottomNavBar(role: role);
        },
      );
    }
  }
}
