import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide OAuthProvider;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ku_report_app/bottom_nav.dart';
import 'package:ku_report_app/screens/user/enter_username.dart';
import 'package:ku_report_app/theme/color.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  String? _errorMessage;

  // Email sign in using Firebase Auth directly
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Firebase Auth directly
      UserCredential userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final uid = userCred.user!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        // In case there's no doc or something's wrong
        setState(() {
          _errorMessage = 'User record does not exist.';
        });
        return;
      }

      final userData = userDoc.data()!;
      final role = userData['role'] as String? ?? 'User';

    if (mounted) {
      // Pass the role to your next screen or store in a global place
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BottomNavBar(
            role: role,
          ),
        ),
      );
    }


    } on FirebaseAuthException catch (e) {
      print('Firebase error code: ${e.code}'); // Debug print
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google sign in using FirebaseAuth and GoogleSignIn
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final googleSignIn = GoogleSignIn(
        clientId: "128318604608-otmejpdaqqqcq99g3u5rcsndg9i8d8i4.apps.googleusercontent.com",
        // scope for google drive
        scopes: <String>[
          'email',
          'https://www.googleapis.com/auth/drive.file'
        ]
      );

      // 1) Force sign out first so user can pick a new account
      await googleSignIn.signOut();

      // 2) Now do a fresh sign in
      final googleUser = await googleSignIn.signIn();
      // User canceled the sign-in
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get authentication details
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 1. Get the current sign-in user
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 2. Check if Firestore doc exists for this user
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await docRef.get();

        // 3. If it doesn't exist, create user
        if (!docSnap.exists || !(docSnap.data()?['username']?.isNotEmpty ?? false)) {
        // Navigate to username page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => EnterUsernamePage(
                isGoogleSignIn: true,
              ),
            ),
          );
        }
      } else {
        // doc exists and has a username
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to sign in with Google';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // Get user-friendly error messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'The password is incorrect.';
      case 'email-already-in-use':
        return 'This email is already in use by another account.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'invalid-credential':
        return 'This email is not registered. Please try another account or sign up';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with green color
          Container(
            width: double.infinity,
            color: customGreenPrimary,
            child: Image.asset('assets/images/signin-background.png'),
          ),

          Positioned(
            top: 40, // adjust for status bar or desired padding
            right: 10,
            child: Image.asset(
              'assets/icons/KU_sublogo_large.png',
              height: 100, // adjust size as needed
            ),
          ),

          // Illustration image
          Container(
            margin: const EdgeInsets.only(top: 120),
            width: double.infinity, // forces the container to take full width
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/illustration-bg-2.png',
                  height: 168,
                ),
              ],
            ),
          ),

          // Rounded white container with login form
          Container(
            margin: const EdgeInsets.only(top: 310),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
        
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: customGreenPrimary,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: UnderlineInputBorder(),
                      floatingLabelStyle: TextStyle(color: customGreenPrimary),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: customGreenPrimary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    cursorColor: customGreenPrimary,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: UnderlineInputBorder(),
                      floatingLabelStyle: TextStyle(color: customGreenPrimary),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: customGreenPrimary,
                          width: 2.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  // const SizedBox(height: 4),

                  // Forgot password button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
  onPressed: () {
    Navigator.pushNamed(context, '/forgot-password');
  },
  child: const Text(
    'Forgot password?',
    style: TextStyle(color: customGreenPrimary),
  ),
),

                  ),

                  // Error message if any
                  if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  // Sign in button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _signInWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customGreenPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  const SizedBox(height: 14),

                  // Divider with OR text
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Google sign in button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Padding(
                      padding: EdgeInsets.only(right: 4.0),
                      child: Image.asset(
                        'assets/icons/google-logo.png',
                        width: 26,
                        height: 26,
                      ),
                    ),
                    label: const Text(
                      'Sign in with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/sign-up');
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: customGreenPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
