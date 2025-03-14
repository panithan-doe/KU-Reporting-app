import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // get collection of user
  final CollectionReference user = FirebaseFirestore.instance.collection('user');

  // CREATE: add a new user
  Future<void> addUser(String name, String email, String phoneNumber, String role) {
    return user.add({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
    });
  }
  
  // READ: get user from database
  Stream<QuerySnapshot> getUserStream() {
    final userStream = user.orderBy('name', descending: false).snapshots();

    return userStream;
  }

  // UPDATE: update user given a doc id
  Future<void> updateUser(String docID, String newName, String newEmail, String newPhoneNumber) {
    return user.doc(docID).update({
      'name': newName,
      'email': newEmail,
      'phoneNumber': newPhoneNumber,
    });
  }

  // DELETE: delete user given a doc id
  Future<void> deleteUser(String docID) {
    return user.doc(docID).delete();
  }

}