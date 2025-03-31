import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/user/enter_username.dart';
import 'package:ku_report_app/theme/color.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  void _navigateToUsernamePage() {
    if (!_formKey.currentState!.validate()) return;

    // Ensure passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => EnterUsernamePage(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          isGoogleSignIn: false,  // not sign in with google
        ) 
      
      )
    );
  } 


  // Map Firebase error codes to user-friendly messages
  // String _getFirebaseErrorMessage(String code) {
  //   switch (code) {
  //     case 'invalid-email':
  //       return 'The email address is not valid.';
  //     case 'email-already-in-use':
  //       return 'This email is already in use by another account.';
  //     case 'weak-password':
  //       return 'The password is too weak.';
  //     case 'operation-not-allowed':
  //       return 'Email/password accounts are not enabled.';
  //     default:
  //       return 'An error occurred. Please try again.';
  //   }
  // }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background container with the same green color and image as the sign‑in page
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
                  'assets/images/illustration-bg-1.png',
                  height: 180,
                ),
              ],
            ),
          ),

          // White rounded container for the sign‑up form
          Positioned(
            top: 320,
            left: 0,
            right: 0,
            bottom: 0, // This makes the container extend to the bottom of the screen
            child: Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: customGreenPrimary,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: UnderlineInputBorder(),
                          floatingLabelStyle: TextStyle(
                            color: customGreenPrimary,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customGreenPrimary),
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
                      const SizedBox(height: 16),
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
                          floatingLabelStyle: TextStyle(
                            color: customGreenPrimary,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customGreenPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        cursorColor: customGreenPrimary,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          border: UnderlineInputBorder(),
                          floatingLabelStyle: TextStyle(
                            color: customGreenPrimary,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: customGreenPrimary),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      if (_errorMessage != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _navigateToUsernamePage,
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
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?"),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/sign-in',
                              );
                            },
                            child: Text(
                              'Sign In',
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
            ),
            ) 
          ),
          Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
              height: 132,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/sign-in'
                      );
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28,)
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
