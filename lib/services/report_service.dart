import 'package:cloud_firestore/cloud_firestore.dart';

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

  // UPDATE: update status

  // delete: delete report

}
