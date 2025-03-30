import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/services/user_service.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class UserInfo extends StatelessWidget {
  UserInfo({super.key, required this.userId});

  final String userId;
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GoBackAppBar(titleText: 'User info'),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                if (data == null) {
                  return const Center(child: Text('No data found'));
                }

                // Extract fields from the "reports" doc
                // Safely read the fields
                final name = data['name'] as String? ?? '';
                final email = data['email'] as String? ?? '';
                final username = data['username'] as String? ?? '';
                final role = data['role'] as String? ?? '';
                final phoneNumber = data['phoneNumber'] as String? ?? '';
                final profileImageBase64 =
                    data['profileImageBase64'] as String? ?? '';
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      UserHeader(
                        profileImageBase64: profileImageBase64,
                        username: username,
                        role: role,
                      ),
                      SizedBox(height: 24),
                      UserDetails(
                        username: username,
                        email: email,
                        name: name,
                        phoneNumber: phoneNumber,
                      ),
                      SizedBox(height: 24),
                      role == 'Admin'
                          ? SizedBox(height: 12)
                          : InkWell(
                            onTap: () {
                              userService.toggleUserRole(userId, role);
                            },
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  width: 0.5,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                role == 'User'
                                    ? 'Upgrade to Technician'
                                    : 'Downgrade to User',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserHeader extends StatelessWidget {
  const UserHeader({
    super.key,
    required this.profileImageBase64,
    required this.username,
    required this.role,
  });

  final String profileImageBase64;
  final String username;
  final String role;

  @override
  Widget build(BuildContext context) {
    ImageProvider? avatarImage;
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64!);
        avatarImage = MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
      }
    }
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey[350],
            backgroundImage: avatarImage,
            child:
                avatarImage == null
                    ? Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
          ),
          SizedBox(height: 12),
          Text('@$username', style: TextStyle(fontSize: 24)),
          Text(
            role,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetails extends StatelessWidget {
  const UserDetails({
    super.key,
    required this.username,
    required this.email,
    required this.name,
    required this.phoneNumber,
  });

  final String username;
  final String email;
  final String name;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Email', email),
          SizedBox(height: 12),
          _buildInfoRow('name', name),
          SizedBox(height: 12),
          _buildInfoRow('phoneNumber', phoneNumber),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Text(
          value == '' ? '-' : value,
          style: TextStyle(color: Colors.grey, fontSize: 20),
        ),
      ],
    );
  }
}
