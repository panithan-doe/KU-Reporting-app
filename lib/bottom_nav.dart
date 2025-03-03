import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/dashboard/dashboard.dart';
import 'package:ku_report_app/screens/home/home.dart';
import 'package:ku_report_app/screens/reports/all_reports.dart';
import 'package:ku_report_app/screens/reports/report_form.dart';
import 'package:ku_report_app/screens/user/profile.dart';
import 'package:ku_report_app/theme/color.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AllReportsScreen(),
    ReportFormScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];

  Widget get currentPage => _pages[_currentIndex];

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? customGreenPrimary : Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color,),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPage,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 72,
        height: 72,

        child: FloatingActionButton(
          backgroundColor: customGreenPrimary,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ReportFormScreen()));
          },

          shape: const StadiumBorder(),

          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
            _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),

            const SizedBox(width: 52),

            _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
            _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
          ],
        ),
      ),
    );
  }
}
