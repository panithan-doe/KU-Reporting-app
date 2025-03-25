import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/reports/my_reports.dart';
import 'package:ku_report_app/theme/color.dart';
import 'package:ku_report_app/widgets/filter_bar.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/listtile_report.dart';

class AllReportsScreen extends StatefulWidget {
  const AllReportsScreen({super.key});

  @override
  State<AllReportsScreen> createState() => _AllReportsScreenState();
}

class _AllReportsScreenState extends State<AllReportsScreen> {
  final ReportService reportService = ReportService();

  // Keep track of which sorting option is selected.
  // "Newest" or "Oldest"
  String _sortOption = 'Newest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),

      // Example custom appBar
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyReportsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 27, 179, 115),
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

      // Now we use our "sorted" stream instead of the plain getAllReportStream()
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSortedReportStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reportList = snapshot.data!.docs;

          return Column(
            children: [
              // FilterBar that triggers the bottom sheet
              FilterBar(
                onSortTap: () => _showSortBottomSheet(context),
                currentSort: _sortOption,
                reportsLength: reportList.length,
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.start,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Text(
              //         '${reportList.length} Reports',
              //         style: const TextStyle(fontSize: 16),
              //       ),
              //     ],
              //   ),
              // ),

              Expanded(
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
            ],
          );
        },
      ),
    );
  }

  /// Decide how to sort based on _sortOption
  Stream<QuerySnapshot> _getSortedReportStream() {
    if (_sortOption == 'Newest') {
      // Sort by postDate descending
      return reportService.getAllReportStream(descending: true);
    } else {
      // Sort by postDate ascending
      return reportService.getAllReportStream(descending: false);
    }
  }

  /// Show bottom sheet so user can pick "Newest" or "Oldest"
  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SizedBox(
          height: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    SizedBox(width: 12),
                    Text(
                      'Sort by',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text("Newest (Default)"),
                trailing: _sortOption == 'Newest'
                    ? const Icon(Icons.check, color: customGreenPrimary)
                    : null,
                onTap: () {
                  setState(() {
                    _sortOption = 'Newest';
                  });
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                title: const Text("Oldest"),
                trailing: _sortOption == 'Oldest'
                    ? const Icon(Icons.check, color: customGreenPrimary)
                    : null,
                onTap: () {
                  setState(() {
                    _sortOption = 'Oldest';
                  });
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
