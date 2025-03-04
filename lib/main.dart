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
      // home: const BottomNavBar(),
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/sign-in' : '/home',
      routes: {
        '/sign-in': (context) => SignInPage(),
        '/home': (context) => BottomNavBar(),
        '/sign-up': (context) => SignUpPage(),
        '/forgot-password': (context) => ForgotPasswordPage(),
      },
    );
  }
}
