import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final CollectionReference notifications = FirebaseFirestore.instance.collection('notifications');

  // READ: get notifications of currentUser
  Stream<QuerySnapshot> getNotificationStreamOfCurrentUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    return notifications
      .where('userId', isEqualTo: currentUser?.uid)
      .orderBy('date', descending: true)
      .snapshots();
  }

  // READ: get unread notifications of currentUser
  Stream<QuerySnapshot> getUnreadNotificationsStream() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return notifications
        .where('userId', isEqualTo: currentUser?.uid)
        .where('unread', isEqualTo: true)
        .snapshots();
  }

  // CREATE: add notification when change report status (by technician)
  Future<void> addNotification(String reportTitle, String status, String userId, String reportId) {
    return notifications.add({
      'reportTitle': reportTitle,
      'status': status,
      'userId': userId,
      'date': Timestamp.now(),
      'unread': true,
      'reportId': reportId,
    });
  }

  // UPDATE: update 'unread' to 'read'
  Future<void> updateUnread(String docId) {
    return notifications.doc(docId).update({
      'unread': false
    });
  }

}