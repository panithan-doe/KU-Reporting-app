import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // get collection of user
  final CollectionReference user = FirebaseFirestore.instance.collection('users');

  // CREATE: add a new user
  Future<void> addUser(String name, String email, String phoneNumber, String role) {
    return user.add({
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'profileImage': ''
    });
  }
  
  // READ: get user from database
  Stream<QuerySnapshot> getUserStream() {
    final userStream = user.orderBy('name', descending: false).snapshots();

    return userStream;
  }

  // UPDATE: update user given a doc id
  Future<void> updateUser(String newName, String newPhoneNumber) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final docId = currentUser?.uid;
    return user.doc(docId).update({
      'name': newName,
      'phoneNumber': newPhoneNumber,
    });
  }

  // DELETE: delete user given a doc id
  Future<void> deleteUser(String docID) {
    return user.doc(docID).delete();
  }
}
