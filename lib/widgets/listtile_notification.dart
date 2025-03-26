import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/reports/report_info.dart';
import 'package:intl/intl.dart';
import 'package:ku_report_app/services/notification_service.dart';

class ListTileNotification extends StatelessWidget {
  ListTileNotification({
    super.key,
    required this.docId,
    required this.reportTitle,
    required this.status,
    required this.date,
    required this.unread,
    required this.reportId,
  });

  final String docId;
  final String reportTitle;
  final String status;
  final Timestamp date;
  final bool unread;
  final String reportId;

  final NotificationService notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // update 'unread' to false
        notificationService.updateUnread(docId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportInfo(docId: reportId)),
        );
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading + Title + Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading
                  Image.asset(
                    'assets/icons/${status == 'Completed'
                        ? 'completed.png'
                        : status == 'Canceled'
                        ? 'canceled.png'
                        : status == 'In progress'
                        ? 'checked.png'
                        : 'error.png' // change later
                        }',
                    width: 44,
                  ),

                  SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title
                      Text(
                        'Your report has been ${status == 'In progress'
                            ? 'checked'
                            : status == 'Completed'
                            ? 'resolved'
                            : status == 'Canceled'
                            ? 'canceled'
                            : 'Error'}.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      // Subtitle 1
                      Text(
                        'TITLE: $reportTitle',
                        style: TextStyle(color: Colors.grey),
                      ),
                      // Subtitle 2
                      Text(
                        'STATUS: $status',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              // End of list
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(height: 4),
                  // Date
                  Text(
                    DateFormat('dd/MM/yyy').format(date.toDate()),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
