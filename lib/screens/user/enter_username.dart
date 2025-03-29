import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/theme/color.dart';

class EnterUsernamePage extends StatefulWidget {
  // We’ll receive the user’s email and password if email signup
  // or the user object if Google sign-in
  final String? email;
  final String? password;

  // For Google sign-in scenario
  final bool isGoogleSignIn;

  const EnterUsernamePage({
    super.key,
    this.email,
    this.password,
    this.isGoogleSignIn = false,
  });

  @override
  State<EnterUsernamePage> createState() => _EnterUsernamePageState();
}

class _EnterUsernamePageState extends State<EnterUsernamePage> {
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // Checks if the username is already taken
  Future<bool> _isUsernameTaken(String username) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();

    return query.docs.isNotEmpty;
  }

  // Called when “Confirm” button is pressed
  Future<void> _onConfirmUsername() async {
    final username = _usernameController.text.trim();

    if (username.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1) Check if username is taken
      final taken = await _isUsernameTaken(username);
      if (taken) {
        setState(() {
          _errorMessage = 'Username "$username" is already taken. Please try another.';
        });
        return;
      }

      // 2) If not taken, either do email+password sign-up or Google sign-in logic

      if (!widget.isGoogleSignIn) {
        // ========== Email/Password scenario ==========
        // Actually create the Firebase Auth user now
        final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email!.trim(),
          password: widget.password!,
        );
        final uid = userCred.user!.uid;

        // Create doc in Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': widget.email!.trim(),
          'username': username,
          'role': 'User',
          'phoneNumber': '',
          'name': '',
        });

        // Go to sign-in page (or do auto-login, up to you)
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/sign-in');
        }
      } else {
        // ========== Google Sign-In scenario ==========
        // Current user should already be signed in with Google
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final uid = user.uid;
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'email': user.email,
            'username': username,
            'role': 'User',
            'phoneNumber': '',
            'name': '',
          });
          // Now navigate to your home page
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred. Please try again.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter your Username'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: const UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Text(_errorMessage!,
                  style: TextStyle(color: Colors.red, fontSize: 14)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _onConfirmUsername,
              style: ElevatedButton.styleFrom(
                backgroundColor: customGreenPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: _isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] 
                  )
            ),
          ],
        ),
      ),
    );
  }
}
