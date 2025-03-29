import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ku_report_app/services/user_service.dart';
import 'package:ku_report_app/theme/color.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  XFile? _imageFile;
  String? _profileImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _profileImageUrl = user?.photoURL;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  // Future<String?> _uploadProfileImage() async {
  //   if (_imageFile == null) return null;

  //   try {
  //     final user = _auth.currentUser;
  //     if (user == null) return null;

  //     // Create a reference to the location you want to store the file
  //     Reference ref = _storage.ref().child('profile_images/${user.uid}');

  //     // Upload the file
  //     await ref.putFile(File(_imageFile!.path));

  //     // Get the download URL
  //     return await ref.getDownloadURL();
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error uploading image: $e')),
  //     );
  //     return null;
  //   }
  // }

  Future<void> _saveProfile() async {
    // Validate inputs
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number cannot be empty')),
      );
      return;
    }

    // Validate phone number format (optional, you can customize)
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(_phoneController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // // Upload image if a new one is selected
      // String? imageUrl;
      // if (_imageFile != null) {
      //   imageUrl = await _uploadProfileImage();
      // }

      // // Update user profile
      // await user.updateProfile(
      //   displayName: _nameController.text.trim(),
      //   photoURL: imageUrl ?? _profileImageUrl,
      // );

      // Update Firestore user document
      // Assuming you have a way to get the user's Firestore document ID
      // You might need to modify this based on your user document structure
      // For example:
      await _userService.updateUser(
        _nameController.text.trim(),
        _phoneController.text.trim(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      // Pop back to previous screen
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F7),
      appBar: GoBackAppBar(titleText: 'Edit profile'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  
                  // // Image from google
                  // CircleAvatar(
                  //   radius: 60,
                  //   backgroundColor: Colors.grey[350],
                  //   backgroundImage: _imageFile != null
                  //       ? FileImage(File(_imageFile!.path))
                  //       : (_profileImageUrl != null
                  //           ? NetworkImage(_profileImageUrl!)
                  //           : null),
                  //   child: _imageFile == null && _profileImageUrl == null
                  //       ? const Icon(
                  //           Icons.person,
                  //           size: 60,
                  //           color: Colors.white,
                  //         )
                  //       : null,
                  // ),
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[350],
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    )
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              

              const SizedBox(height: 20),

              // Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Phone Number TextField
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'xxx-xxx-xxxx',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: customGreenPrimary,
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Save Changes',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:ku_report_app/theme/color.dart';
// import 'package:ku_report_app/widgets/go_back_appbar.dart';
// import 'package:ku_report_app/services/user_service.dart';

// // Import the Google Drive service
// import 'package:ku_report_app/services/google_drive_service.dart';

// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});

//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final UserService _userService = UserService();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // For picking image
//   XFile? _imageFile;

//   // For user name & phone
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;

//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     final user = _auth.currentUser;
//     // We'll fetch Firestore user doc to get any existing data
//     // But for simplicity, let's just start with what's in the FirebaseAuth user
//     _nameController = TextEditingController(text: user?.displayName ?? '');
//     _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   // Pick image from gallery
//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = pickedFile;
//       });
//     }
//   }

//   // The main function to handle saving
//   Future<void> _saveProfile() async {
//     if (_nameController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Name cannot be empty')),
//       );
//       return;
//     }
//     if (_phoneController.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Phone number cannot be empty')),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final user = _auth.currentUser;
//       if (user == null) {
//         throw Exception('No user logged in');
//       }

//       // 1) Upload the selected image to Google Drive if one was chosen
//       String? driveLink; // we'll store the final link or fileId
//       if (_imageFile != null) {
//         final googleDriveService = GoogleDriveService();

//         // A) Sign in with Google to get permission for Drive
//         final account = await googleDriveService.signIn();
//         if (account == null) {
//           // User canceled the sign-in or it failed
//           throw Exception('Google Drive sign-in failed');
//         }

//         // B) Create Drive API client
//         final driveApi = await googleDriveService.getDriveApi(account);
//         if (driveApi == null) {
//           throw Exception('Unable to create Drive API');
//         }

//         // C) Upload the file
//         final fileId = await googleDriveService.uploadFile(
//           driveApi: driveApi,
//           filePath: _imageFile!.path,
//           fileName: '${user.uid}_profileImage.png',
//         );

//         if (fileId != null) {
//           // D) Make the file public (optional – if you want a direct link)
//           await googleDriveService.makeFilePublic(driveApi, fileId);

//           // E) Get the direct link (webContentLink)
//           final fileInfo = await googleDriveService.getFileInfo(driveApi, fileId);
//           if (fileInfo != null && fileInfo.webContentLink != null) {
//             driveLink = fileInfo.webContentLink;
//             // Optional: Sometimes the link has extra query params
//             // You can also use https://drive.google.com/uc?id=<FILE_ID>
//           } else {
//             // Fallback: store just the fileId
//             driveLink = 'https://drive.google.com/uc?id=$fileId';
//           }
//         }
//       }

//       // 2) Update the Firestore doc for this user
//       //    We'll assume user doc is "users/{uid}"
//       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

//       // Build data to update
//       final updatedData = <String, dynamic>{
//         'name': _nameController.text.trim(),
//         'phoneNumber': _phoneController.text.trim(),
//       };

//       // If we successfully got a Drive link, include it
//       if (driveLink != null) {
//         updatedData['profileImageUrl'] = driveLink;
//       }

//       await userDoc.set(updatedData, SetOptions(merge: true));

//       // Show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Profile updated successfully')),
//       );

//       Navigator.pop(context);
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating profile: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2F5F7),
//       appBar: GoBackAppBar(titleText: 'Edit profile'),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               // Profile image preview
//               Stack(
//                 children: [
//                   // If user picked a new image, show it
//                   // else show a default icon
//                   CircleAvatar(
//                     radius: 60,
//                     backgroundColor: Colors.grey[350],
//                     backgroundImage: 
//                       _imageFile != null ? FileImage(File(_imageFile!.path)) : null,
//                     child: _imageFile == null
//                         ? const Icon(Icons.person, size: 60, color: Colors.white)
//                         : null,
//                   ),
//                   // Camera icon to pick a new image
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: InkWell(
//                       onTap: _pickImage,
//                       child: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: Colors.grey[400],
//                           shape: BoxShape.circle,
//                           border: Border.all(color: Colors.white, width: 3),
//                         ),
//                         child: const Icon(
//                           Icons.camera_alt,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 20),
//               // Name TextField
//               TextField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//               // Phone TextField
//               TextField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   labelText: 'Phone Number',
//                   hintText: 'xxx-xxx-xxxx',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),
//               // Save Button
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _saveProfile,
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 50),
//                   backgroundColor: customGreenPrimary,
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Save Changes',
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
