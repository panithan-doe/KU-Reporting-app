// dashboard_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<Map<String, int>> getStatusCounts({String category = 'ทั้งหมด'}) {
    
    Query query = _firestore.collection('reports');

    if (category != 'ทั้งหมด') {
      query = query.where('category', isEqualTo: category);
    }

    return query.snapshots().map((snapshot) {
      int pendingCount = 0;    // "รอรับการแก้ไข"
      int inProgressCount = 0; // "กำลังดำเนินการ"
      int completedCount = 0;  // "เสร็จสิ้น"
      int canceledCount = 0;   // "ยกเลิก"

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String? ?? '';

        if (status == 'Pending') {
          pendingCount++;
        } else if (status == 'In progress') {
          inProgressCount++;
        } else if (status == 'Completed') {
          completedCount++;
        } else if (status == 'Canceled') {
          canceledCount++;
        }
      }

      
      return {
        'Pending': pendingCount,
        'In Progress': inProgressCount,
        'Completed': completedCount,
        'Canceled': canceledCount,
      };
    
    });
      
  }
}
