import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/notification_service.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';
import 'package:ku_report_app/widgets/listtile_notification.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationService notiService = NotificationService();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: GoBackAppBar(titleText: 'Notification'),
      body: StreamBuilder<QuerySnapshot>(
        stream: notiService.getNotificationStreamOfCurrentUser(), 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final notificationList = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                  itemCount: notificationList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = notificationList[index];
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    String docId = document.id;

                    return ListTileNotification(
                      docId: docId,
                      reportTitle: data['reportTitle'],
                      status: data['status'],
                      date: data['date'],
                      unread: data['unread'],
                      reportId: data['reportId'],

                    );
                  },
                )
                ),
              ],
            );
            
          } else {
            return const Center(child: Text('No notification'));
          }
        },
      ),
    );
  }
}
