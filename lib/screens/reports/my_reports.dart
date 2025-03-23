import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';
import 'package:ku_report_app/widgets/listtile_report.dart';

class MyReportsPage extends StatelessWidget {
  MyReportsPage({super.key});

  final ReportService reportService = ReportService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: GoBackAppBar(titleText: 'My reports'),

      body: Container(
        color: const Color(0xFFF2F5F7),
        child: StreamBuilder<QuerySnapshot>(
          stream: reportService.getReportOfCurrentUserId(),
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