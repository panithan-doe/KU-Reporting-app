import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/dashboard/dashboard.dart';
import 'package:ku_report_app/screens/reports/all_reports.dart';
import 'package:ku_report_app/screens/reports/my_reports.dart';
import 'package:ku_report_app/screens/user/notification.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/listtile_report.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: const CustomAppBar(),
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
  const CustomAppBar({super.key});

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
              IconButton(
  icon: const Icon(Icons.notifications_none, size: 28),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationScreen(), // ✅ ไปยังหน้า Notification
      ),
    );
  },
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
  const GreetingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Hi there, username 👋',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
        DashboardCard(
          icon: Icons.dashboard,
          title: 'Dashboard',
          color: Colors.green.shade100,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          },
        ),
        DashboardCard(
          icon: Icons.insert_drive_file,
          title: 'Reports',
          color: Colors.blue.shade100,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AllReportsScreen()),
            );
          },
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
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final reportList = snapshot.data!.docs;

              return Expanded(
                child: ListView.builder(
                  itemCount: reportList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = reportList[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String docId = document.id;

                    return ListTileReport(
                      docId: docId,
                      image: data['image'],
                      title: data['title'],
                      location: data['location'],
                      status: data['status'],
                      postDate: data['postDate'],
                      category: data['category'],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
