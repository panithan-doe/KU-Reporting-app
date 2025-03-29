import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/user/edit_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 14,),
          ProfileHeader(),
          ProfileDetails(user: user),
          EditProfileButton(),
          SizedBox(height: 14,),
          SignOutButton(),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
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
            radius: 60,
            backgroundColor: Colors.grey[350],
            child: Icon(Icons.person, size: 60, color: Colors.white),
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
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow("Name", user?.displayName ?? "-"),
          const SizedBox(height: 24),
          _buildInfoRow("Email", user?.email ?? "-"),
          const SizedBox(height: 24),
          _buildInfoRow("Phone Number", user?.phoneNumber ?? "-"),
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileScreen()));
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            Text(
              "Edit Profile",
              style: TextStyle(color: Colors.blue, fontSize: 18),
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
                  const Icon(Icons.logout, color: Colors.red, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    "Sign Out",
                    style: TextStyle(color: Colors.red, fontSize: 18),
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


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text('No user logged in')),
//       );
//     }

//     final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F5F7),
//       appBar: AppBar(
//         title: const Text("Profile", style: TextStyle(fontSize: 32)),
//         backgroundColor: Colors.white,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: docRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.data!.exists) {
//             return const Center(child: Text('No profile found'));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final name = data['name'] ?? 'Unknown';
//           final phone = data['phoneNumber'] ?? 'Unknown';
//           final profileImageUrl = data['profileImageUrl'] ?? null;

//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 Container(
//                   color: Colors.white,
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       // Profile Image
//                       CircleAvatar(
//                         radius: 60,
//                         backgroundColor: Colors.grey[300],
//                         backgroundImage: profileImageUrl != null
//                             ? NetworkImage(profileImageUrl)
//                             : null,
//                         child: profileImageUrl == null
//                             ? const Icon(Icons.person, size: 60, color: Colors.white)
//                             : null,
//                       ),
//                       const SizedBox(width: 16),
//                       // Name + Phone
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(name, style: const TextStyle(fontSize: 24)),
//                             const SizedBox(height: 8),
//                             Text(phone, style: const TextStyle(color: Colors.grey)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // ... More UI ...
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
