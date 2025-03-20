import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: EdgeInsets.all(16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // leading
                Image.asset(
                  width: 52,
                  height: 52,
                  'assets/icons/KU_sublogo.png',
                  fit: BoxFit.contain,
                ),
                // actions
                IconButton(
                  icon: Icon(Icons.notifications_none, size: 28),
                  onPressed: () {
                    // ...
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: Center(
        child: Text('Home'),
      ),
    );
  }
}
