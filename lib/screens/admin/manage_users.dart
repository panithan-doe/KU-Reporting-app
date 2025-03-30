import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/user_service.dart';
import 'package:ku_report_app/widgets/listtile_user.dart';

class ManageUsersScreen extends StatelessWidget {
  ManageUsersScreen({super.key});

  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppBar(
            backgroundColor: const Color(0xFFF2F5F7),
            title: const Text(
              "Manage Users",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userService.getUserStream(), 
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userList = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: userList.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = userList[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      String docId = document.id;

                      return ListTileUser(
                        docId: docId,
                        image: data['profileImageBase64'],
                        username: data['username'],
                        name: data['name'],
                        role: data['role'],
                      );
                    }
                  )
                )
              ]
            );

          } else {
            return const Text('No users');
          }
        }
      ),
    );
  }
}