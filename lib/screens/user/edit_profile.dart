import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // If the user picks a new image from the gallery, we store it here:
  File? _pickedFile;

  // We'll store the existing base64-encoded image as a MemoryImage:
  MemoryImage? _existingAvatar;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initUserFields();
  }

  /// Fetch current user doc to get name, phone, and existing base64 image.
  Future<void> _initUserFields() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Initialize controllers with default data from user
    _nameController = TextEditingController(text: user.displayName ?? '');
    _phoneController = TextEditingController(text: user.phoneNumber ?? '');

    // Now fetch Firestore doc for additional info
    final docSnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      // If they have a name/phone in Firestore, override:
      if (data.containsKey('name')) {
        _nameController.text = data['name'] ?? '';
      }
      if (data.containsKey('phoneNumber')) {
        _phoneController.text = data['phoneNumber'] ?? '';
      }

      // If there's a base64 image, decode it into a MemoryImage
      if (data.containsKey('profileImageBase64') &&
          data['profileImageBase64'] != null &&
          (data['profileImageBase64'] as String).isNotEmpty) {
        try {
          final String base64String = data['profileImageBase64'];
          final bytes = base64Decode(base64String);
          _existingAvatar = MemoryImage(bytes);
        } catch (e) {
          debugPrint('Error decoding existing base64 image: $e');
        }
      }
    }

    // Trigger a rebuild once we've fetched Firestore data
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Picks image from gallery and stores the [File] in `_pickedFile`.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedFile = File(pickedFile.path);
      });
    }
  }

  /// Converts the picked file to base64, then updates Firestore document.
  Future<void> _saveProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is logged in');
      }

      setState(() {
        _isLoading = true;
      });

      // 1) Convert file to base64 if a file is picked.
      String? base64Image;
      if (_pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      }

      // 2) Update Firestore with form data & base64 image
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        // Only update if we have a new base64:
        if (base64Image != null) 'profileImageBase64': base64Image,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
              // Profile Image + pick button 
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[350],
                    // If we have a newly picked file, show that
                    // else if we have an existing MemoryImage, show that
                    // else show an icon
                    backgroundImage: _pickedFile != null
                        ? FileImage(_pickedFile!)
                        : _existingAvatar,
                    child: (_pickedFile == null && _existingAvatar == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
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

              // Name
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
                child: _isLoading
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
