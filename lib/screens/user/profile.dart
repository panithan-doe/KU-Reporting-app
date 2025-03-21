import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser; // ดึงข้อมูลผู้ใช้ปัจจุบัน

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
  title: Padding(
    padding: const EdgeInsets.only(left: 16),
    child: const Text(
      "Profile",
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  ),
  backgroundColor: Colors.grey[200],
  elevation: 0,
),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileHeader(),
            ProfileDetails(user: user),
            const EditProfileButton(),
            const Divider(thickness: 1, height: 20),
            SignOutButton(),
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            "Your Account",
            style: TextStyle(color: Colors.grey[600], fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final User? user;

  const ProfileDetails({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Name", user?.displayName ?? "Doe DooDoe"),
          const SizedBox(height: 30),
          _buildInfoRow("Email", user?.email ?? "example@gmail.com"),
          const SizedBox(height: 30),
          _buildInfoRow("Phone Number", user?.phoneNumber ?? "081-xxx-xxxx"),
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
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          value,
          style: TextStyle(color: Colors.grey[700], fontSize: 20),
        ),
      ],
    );
  }
}

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.edit, color: Colors.blue, size: 22),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.blue, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class SignOutButton extends StatelessWidget {
  const SignOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          const Icon(Icons.logout, color: Colors.red, size: 22),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/sign-in');
              }
            },
            child: const Text(
              "Sign Out",
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
