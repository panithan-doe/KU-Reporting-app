import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/listtile_report.dart';

class AllReportsScreen extends StatelessWidget {
  AllReportsScreen({super.key});

  final ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
            backgroundColor: const Color(0xFFF2F5F7),
            title: const Text(
              "Reports",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // ...
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50808E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View My Reports'),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF2F5F7),
        child: StreamBuilder<QuerySnapshot>(
          stream: reportService.getAllReportStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final reportList = snapshot.data!.docs;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${reportList.length} Reports',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: const [
                          Text('Category', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 12),
                          Text('Sort by', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
