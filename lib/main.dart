import 'package:flutter/material.dart';
import 'package:ku_report_app/bottom_nav.dart';
import 'package:ku_report_app/theme/color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KU Reporting App',
      theme: ThemeData(
        primarySwatch: customGreenPrimary,
      ),
      home: const BottomNavBar(),
    );
  }
}