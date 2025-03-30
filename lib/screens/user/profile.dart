import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/user/edit_profile.dart';
import 'package:ku_report_app/services/user_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      // backgroundColor: Colors.amber,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          backgroundColor: Colors.white,
          title: const Text(
            "Profile",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: userService.getCurrentUser(),
        builder: (context, snapshot) {
          // 1. Handle error
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }

          // 2. Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. If no data
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          DocumentSnapshot document = snapshot.data!;
          final data = document.data() as Map<String, dynamic>;

          final String name = data['name'].toString().trim() == '' ? '-' : data['name'];
          final String email = data['email'].toString().trim() == '' ? '-' : data['email'];
          final String username = data['username'].toString().trim() == '' ? '-' : data['username'];
          final String phoneNumber = data['phoneNumber'].toString().trim() == '' ? '-' : data['phoneNumber'];

          final String? profileImageBase64 = data['profileImageBase64'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14),
              ProfileHeader(profileImageBase64: profileImageBase64,),
              ProfileDetails(
                name: name,
                email: email,
                username: username,
                phoneNumber: phoneNumber,
              ),
              EditProfileButton(),
              SizedBox(height: 14),
              SignOutButton(),
            ],
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String? profileImageBase64; // Pass in from your snapshot data

  const ProfileHeader({
    super.key,
    this.profileImageBase64,
  });

  @override
  Widget build(BuildContext context) {
    // Decode base64 if it's not null
    ImageProvider? avatarImage;
    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(profileImageBase64!);
        avatarImage = MemoryImage(bytes);
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
      }
    }

    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Your Account",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey[350],
            backgroundImage: avatarImage,
            child: avatarImage == null 
                ? Icon(Icons.person, size: 60, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}


class ProfileDetails extends StatelessWidget {
  const ProfileDetails({
    super.key,
    required this.name,
    required this.email,
    required this.username,
    required this.phoneNumber,
  });

  final String name;
  final String email;
  final String username;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Name", name),
          const SizedBox(height: 20),
          _buildInfoRow("Email", email),
          const SizedBox(height: 20),
          _buildInfoRow("Username", username),
          const SizedBox(height: 20),
          _buildInfoRow("Phone Number", phoneNumber),
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
        Text(value, style: TextStyle(color: Colors.grey, fontSize: 20)),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfileScreen()),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            Text(
              "Edit Profile",
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // Top Title
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Sign Out Button
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/sign-in');
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.logout, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
