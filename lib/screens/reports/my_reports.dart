import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/theme/color.dart';
import 'package:ku_report_app/widgets/filter_bar.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';
import 'package:ku_report_app/widgets/listtile_report.dart';
import 'package:intl/intl.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  final ReportService reportService = ReportService();

  // We’ll store the current sort option in this variable.
  // By default, let's assume "Newest (Default)" is selected.
  String _sortOption = 'Newest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: GoBackAppBar(titleText: 'My reports'),
      body: StreamBuilder<QuerySnapshot>(
          // Use a helper method to get the correct stream based on _sortOption
          stream: _getSortedReportStream(),
          builder: (context, snapshot) {

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/empty-box.png', width: 120,),
                    SizedBox(height: 8,),
                    Text('No reports yet', style: TextStyle(fontSize: 24),),
                    SizedBox(height: 4,),
                    Text('Send your report and it show here.'),
                  ],
                )
              );
            }

            if (snapshot.hasData) {
              final reportList = snapshot.data!.docs;

              return Column(
                children: [
                  // We pass a callback so that the FilterBar can trigger the modal
                  FilterBar(
                    onSortTap: () => _showSortBottomSheet(context),
                    currentSort: _sortOption,
                    reportsLength: reportList.length,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: reportList.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = reportList[index];
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;

                        String docId = document.id;

                        // images array logic
                        final List<dynamic>? imagesList = data['images'] as List<dynamic>?;
                        
                        String firstBase64 = '';
                        if (imagesList != null && imagesList.isNotEmpty) {
                          firstBase64 = imagesList[0] as String;
                        }

                        final Timestamp? postDateTimestamp = data['postDate'] as Timestamp?;
                        final postDateString = postDateTimestamp != null
                          ? DateFormat('dd-MM--yyy').format(postDateTimestamp.toDate())
                          : '';

                        return ListTileReport(
                          docId: docId,
                          images: firstBase64,
                          title: data['title'],
                          location: data['location'],
                          status: data['status'],
                          postDate: postDateString,
                          category: data['category'],
                        );
                      },
                    ),
                  ),
                ],
              );
              
            } else {
              return const Center(child: Text('No reports'),);
            }
          },
        ),
      
    );
  }

  // This function returns a Firestore stream based on the currently selected sort order
  Stream<QuerySnapshot> _getSortedReportStream() {
    if (_sortOption == 'Newest') {
      // Sort by postDate descending == newest first
      return reportService.getReportOfCurrentUserId(descending: true);
    } else {
      // Sort by postDate ascending == oldest first
      return reportService.getReportOfCurrentUserId(descending: false);
    }
  }

  // This function shows the modal bottom sheet with “Newest” and “Oldest” items
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
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 1, )
                )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 12,),
                  Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
            ListTile(
              title: const Text("Newest (Default)"),
              trailing: _sortOption == 'Newest'
                      ? const Icon(Icons.check, color: customGreenPrimary,)
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
                      ? const Icon(Icons.check, color: customGreenPrimary,) 
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
