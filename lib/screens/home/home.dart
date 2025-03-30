import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/dashboard/dashboard.dart';
import 'package:ku_report_app/screens/reports/all_reports.dart';
import 'package:ku_report_app/screens/reports/my_reports.dart';
import 'package:ku_report_app/screens/user/notification.dart';
import 'package:ku_report_app/services/notification_service.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/listtile_report_home.dart';
import 'package:firebase_auth/firebase_auth.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GreetingSection(),
            SizedBox(height: 16),
            DashboardSection(),
            SizedBox(height: 24),
            ReportsSection(),
          ],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/icons/KU_sublogo.png',
                width: 52,
                height: 52,
                fit: BoxFit.contain,
              ),

              StreamBuilder<QuerySnapshot>(
                stream: notificationService.getUnreadNotificationsStream(), 
                builder: (context, snapshot) {
                  bool hasUnread = snapshot.hasData && 
                      (snapshot.data?.docs.isNotEmpty ?? false);

                  return IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationScreen(), // ✅ ไปยังหน้า Notification
                        ),
                      );
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_none, size: 28),
                        if (hasUnread) 
                          Positioned(
                              right: 0,
                              top: -1,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          )
                      ],
                    )
                  );
                }
              ),

              
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class GreetingSection extends StatelessWidget {
  GreetingSection({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text(
            'Loading...',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Text(
            'Welcome 👋',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'];
        final username = data['username'];
        // ถ้ามี name ที่เป็น String และไม่ว่างให้ใช้ name ถ้าไม่ก็ใช้ username (หรือ 'User' ถ้า username ไม่ใช่ String)
        final displayName = (name is String && name.isNotEmpty)
            ? name
            : (username is String && username.isNotEmpty ? username : 'User');

        return Text(
          'Welcome, $displayName 👋',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}





class DashboardSection extends StatelessWidget {
  const DashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllReportsScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/reports.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/dashboard.png', fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportsSection extends StatelessWidget {
  ReportsSection({super.key});

  final ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My reports',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyReportsPage()),
                );
              }, 
              child: const Text('View all >')
            ),
          ],
        ),

        SizedBox(height: 16),
        // List of My Reports
        Container(
          height: 300,
          color: const Color(0xFFF2F5F7),
          child: StreamBuilder<QuerySnapshot>(
            stream: reportService.getReportOfCurrentUserId(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final reportList = snapshot.data!.docs;
                
                return ListView.builder(
                    itemCount: reportList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = reportList[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String docId = document.id;

                      return ListTileReportHome(
                        docId: docId,
                        image: data['image'],
                        title: data['title'],
                        location: data['location'],
                        status: data['status'],
                        postDate: data['postDate'],
                        category: data['category'],
                      );
                    },
                );
              } else {
                return const Center(child: Text('No notifications yet'),);
              }

            },
          ),
        ),
      ],
    );
  }
}
