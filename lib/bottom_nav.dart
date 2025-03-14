import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/admin/manage_users.dart';
import 'package:ku_report_app/screens/dashboard/dashboard.dart';
import 'package:ku_report_app/screens/home/home.dart';
import 'package:ku_report_app/screens/reports/all_reports.dart';
import 'package:ku_report_app/screens/reports/report_form.dart';
import 'package:ku_report_app/screens/user/profile.dart';
import 'package:ku_report_app/theme/color.dart';

// class BottomNavBar extends StatefulWidget {
//   final String role;

//   const BottomNavBar({
//     super.key,
//     required this.role,
//   });

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _currentIndex = 0;

//   final List<Widget> userPages = const [
//     HomeScreen(),
//     AllReportsScreen(),
//     ReportFormScreen(),
//     DashboardScreen(),
//     ProfileScreen(),
//   ];

//     final List<Widget> technicianPages = const [
//     HomeScreen(),
//     AllReportsScreen(),
//     // No form at index 2 for tech (or an empty container)
//     DashboardScreen(),
//     ProfileScreen(),
//   ];

//   final List<Widget> adminPages = const [
//     HomeScreen(),
//     AllReportsScreen(),
//     // ReportFormScreen(),
//     DashboardScreen(),
//     ProfileScreen(),
//     // Additional pages for Admin
//     // ManageUserScreen(),
//     // or something else
//   ];

//   // Widget get currentPage => _pages[_currentIndex];

//   Widget _buildNavItem({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final isSelected = _currentIndex == index;
//     final color = isSelected ? customGreenPrimary : Colors.grey;

//     return InkWell(
//       onTap: () {
//         setState(() {
//           _currentIndex = index;
//         });
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4.0),
//         child: SizedBox(
//           width: 72,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: color,),
//               const SizedBox(height: 4),
//               Text(label, style: TextStyle(color: color, fontSize: 14)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final role = widget.role;

//     bool isAdmin = role == 'Admin';
//     bool isTechnician = role == 'Technician';
//     bool isUser = role == 'User';

//         // Decide which set of pages and which nav bar to show:
//     final pages = isAdmin
//         ? adminPages
//         : isTechnician
//             ? technicianPages
//             : userPages; // default for normal User

//     Widget bottomBar;
//     if (isAdmin) {
//       bottomBar = _buildAdminNavBar();
//     } else if (isTechnician) {
//       bottomBar = _buildTechnicianNavBar();
//     } else {
//       bottomBar = _buildUserNavBar();
//     }

//     final fab = isUser
//       ? FloatingActionButton(
//           backgroundColor: customGreenPrimary,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const ReportFormScreen()),
//             );
//           },
//           shape: const StadiumBorder(),
//           child: const Icon(Icons.add, color: Colors.white, size: 28),
//         )
//       : null;

//     return Scaffold(
//       body: IndexedStack(
//         index: _currentIndex,
//         children: isAdmin ? [
//           HomeScreen(),
//           AllReportsScreen(),
//           ReportFormScreen(),     // the middle
//           DashboardScreen(),
//           ProfileScreen(),
//         ] : [
//           HomeScreen(),
//           AllReportsScreen(),
//           // The third item is only for normal user & admin
//           // but not for technician => so we can conditionally
//           // add an "empty" placeholder if it's technician.
//           if (!isTechnician) ReportFormScreen() else Container(),
//           DashboardScreen(),
//           ProfileScreen(),
//         ],
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: isUser ? SizedBox(
//         width: 72,
//         height: 72,
//         child: FloatingActionButton(
//           backgroundColor: customGreenPrimary,
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ReportFormScreen()),
//             );
//           },
//           shape: const StadiumBorder(),
//           child: const Icon(Icons.add, color: Colors.white, size: 28),
//         ),
//       )
//       : null,
//       bottomNavigationBar: isTechnician
//         ? _buildTechnicianNavBar() //
//         : _buildDefaultNavBar(isAdmin),
//     );
//   }

//   Widget _buildDefaultNavBar(bool isAdmin) {
//     return BottomAppBar(
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 6.0,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
//             _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),

//             const SizedBox(width: 52),

//             _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
//             _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
//           ],
//         ),
//       );
//   }

//   Widget _buildTechnicianNavBar() {
//   // Example: remove the gap for the FAB.
//     return BottomAppBar(
//       // no notch if no floatingActionButton
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
//           _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),
//           _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
//           _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdminNavBar() {
//   // Example: remove the gap for the FAB.
//     return BottomAppBar(
//       // no notch if no floatingActionButton
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
//           _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),
//           _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
//           _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
//         ],
//       ),
//     );
//   }
// }

class BottomNavBar extends StatefulWidget {
  final String role;

  const BottomNavBar({super.key, required this.role});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  // For convenience, define how many pages each role has
  final List<Widget> userPages = const [
    HomeScreen(),
    AllReportsScreen(),
    ReportFormScreen(),
    DashboardScreen(),
    ProfileScreen(),
  ];


  final List<Widget> technicianPages = const [
    HomeScreen(),
    AllReportsScreen(),
    // No form at index 2 for tech (or an empty container)
    DashboardScreen(),
    ProfileScreen(),
  ];

  final List<Widget> adminPages = const [
    HomeScreen(),
    AllReportsScreen(),
    ManageUsersScreen(),
    DashboardScreen(),
    ProfileScreen(),
    // Additional pages for Admin, e.g. ManageUsersScreen()
  ];

  // Reusable method to build a single nav item
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? customGreenPrimary : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
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
    final role = widget.role;
    final isAdmin = role == 'Admin';
    final isTechnician = role == 'Technician';
    final isUser = role == 'User';

    // Decide which set of pages and which nav bar to show:
    final pages =
        isAdmin
            ? adminPages
            : isTechnician
            ? technicianPages
            : userPages; // default for normal User

    Widget bottomBar;
    if (isAdmin) {
      bottomBar = _buildAdminNavBar();
    } else if (isTechnician) {
      bottomBar = _buildTechnicianNavBar();
    } else {
      bottomBar = _buildUserNavBar();
    }

    // If only "User" sees a FAB, set it here, otherwise null
    // (or define custom logic for each role)
    final fab =
        isUser
            ? FloatingActionButton(
              backgroundColor: customGreenPrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportFormScreen(),
                  ),
                );
              },
              shape: const StadiumBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
            : null;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(width: 72, height: 72, child: fab),
      bottomNavigationBar: bottomBar,
    );
  }

  // ------- Different role-specific NavBars -------

  Widget _buildUserNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),

          // Space for the floating action button
          const SizedBox(width: 52),

          _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
        ],
      ),
    );
  }

  Widget _buildTechnicianNavBar() {
    return BottomAppBar(
      // no notch if no floatingActionButton
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),
          _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 2),
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 3),
        ],
      ),
    );
  }

  Widget _buildAdminNavBar() {
    return BottomAppBar(
      // no notch if no floatingActionButton
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(icon: Icons.home, label: 'Home', index: 0),
          _buildNavItem(icon: Icons.map_outlined, label: 'Reports', index: 1),
          _buildNavItem(icon: Icons.people, label: 'Users', index: 2),
          _buildNavItem(icon: Icons.pie_chart, label: 'Dashboard', index: 3),
          _buildNavItem(icon: Icons.person, label: 'Profile', index: 4),
        ],
      ),
    );
  }
}
