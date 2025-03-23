import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  // get collection of report
  final CollectionReference report = FirebaseFirestore.instance.collection(
    'reports',
  );

  // CREATE: add a new report

  // READ: get all report
  Stream<QuerySnapshot> getAllReportStream() {
    final reportStream = report.orderBy('postDate', descending: false).snapshots();

    return reportStream;
  }

  // READ: get reports by userId
  Stream<QuerySnapshot> getReportOfCurrentUserId() {
    // get current user
    final currentUser = FirebaseAuth.instance.currentUser;
    print("this isssssssssssssss ${currentUser?.uid}");

    final reportStream = report
      .where('userId', isEqualTo: currentUser?.uid)
      // .orderBy('postDate')
      .snapshots();

      return reportStream;
  }

  // UPDATE: update status to "In progress"
  Future<void> updateStatus(String docID, String status) {
    return report.doc(docID).update({
      'status': status
    });
  }

  // delete: delete report

}
