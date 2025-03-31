import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';
import 'package:ku_report_app/screens/reports/report_success.dart';

/// Helper to build dropdown items from a list of strings.
List<DropdownMenuItem<String>> buildDropdownItems(List<String> items) {
  return items.map((item) {
    return DropdownMenuItem<String>(
      value: item,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(item, style: const TextStyle(fontSize: 18)),
      ),
    );
  }).toList();
}

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  // Max image limit
  static const int maxImages = 5;

  // Controllers / states
  final ImagePicker _picker = ImagePicker();
  final List<File> _images = [];

  // The user must enter a title & description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // We store the selected category/location
  String? _selectedCategory;
  String? _selectedLocation;

  // For the date
  final DateTime _currentDate = DateTime.now();

  // Example static lists for categories & locations
  final List<String> categories = [
    "ไฟฟ้า",
    "ประปา",
    "อุปกรณ์ไฟฟ้า",
    "โครงสร้างและอาคาร",
    "ไอที",
    "ระบบความปลอดภัย",
    "เฟอร์นิเจอร์",
    "พื้นที่ภายนอกอาคาร",
  ];

  final List<String> locations = [
    "คณะเกษตร",
    "คณะบริหารธุรกิจ",
    "คณะประมง",
    "คณะมนุษยศาสตร์",
    "คณะเศรษฐศาสตร์",
    "คณะวิทยาศาสตร์",
    "คณะวิศวกรรมศาสตร์",
    "คณะวนศาสตร์",
    "คณะศึกษาศาสตร์",
    "คณะสังคมศาสตร์",
    "คณะสัตวแพทยศาสตร์",
    "คณะสิ่งแวดล้อม",
    "คณะสถาปัตยกรรมศาสตร์",
    "บัณฑิตวิทยาลัย",
    "โครงสร้างและอาคาร",
    "วิทยาลัยสิ่งแวดล้อม",
    "วิทยาลัยเทคนิคการสัตวแพทย์",
    "อาคารศูนย์เรียนรวม 1",
    "อาคารศูนย์เรียนรวม 2",
    "อาคารศูนย์เรียนรวม 3",
    "อาคารศูนย์เรียนรวม 4",
    "หอประชุมใหญ่",
    "หอสมุด มก.",
    "สำนักบริการคอมพิวเตอร์",
    "ศูนย์หนังสือ มก.",
    "อาคารสารนิเทศ 50 ปี",
    "อาคารจักรพันธ์เพ็ญศิริ",
    "อาคารเทพศาสตร์สถิตย์",
    "อาคาร KU Home",
    "โรงอาหารกลาง 1",
    "โรงอาหารกลาง 2",
    "สนามอินทรีจันทรสถิตย์",
    "สำนักการกีฬา",
    "สหกรณ์ร้านค้า มก.",
    "สหกรณ์ออมทรัพย์ มก",
    "สถานพยาบาล มก.",
    "ศูนย์วิจัยและควบคุมศัตรูพืชฯ",
    "อาคาร KU-Green",
    "ศูนย์การศึกษานานาชาติ",
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Camera
  Future<void> _pickImageFromCamera() async {
    if (_images.length >= maxImages) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  /// Gallery
  Future<void> _pickImageFromGallery() async {
    if (_images.length >= maxImages) return;
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles
          .take(maxImages - _images.length)
          .map((xFile) => File(xFile.path));
      setState(() {
        _images.addAll(newImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  /// Validate required fields, then save to Firestore if valid
  Future<void> _submitReport() async {
    // 1) Validate required fields
    if (_images.isEmpty) {
      _showErrorSnackBar("Please add at least one photo.");
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar("Please enter a title.");
      return;
    }
    if (_selectedCategory == null) {
      _showErrorSnackBar("Please select a category.");
      return;
    }
    if (_selectedLocation == null) {
      _showErrorSnackBar("Please select a location.");
      return;
    }

    try {
      // 2) Convert all images to base64
      final List<String> base64Images = [];
      for (final file in _images) {
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);
        base64Images.add(base64Str);
      }

      // 3) Build the doc data
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar("No logged-in user found");
        return;
      }

      final docData = {
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "category": _selectedCategory,
        "location": _selectedLocation,
        "images": base64Images,            // array of base64
        "postDate": Timestamp.now(),       // store current time
        "status": "Pending",              // default to pending
        "userId": user.uid,
      };

      // 4) Write to Firestore (under "reports" collection)
      await FirebaseFirestore.instance.collection("reports").add(docData);

      // 5) If success, navigate to success screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ReportSuccessScreen()),
      );
    } catch (e) {
      _showErrorSnackBar("Error: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GoBackAppBar(titleText: "New Report"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE PICKER
              Center(
                child: ReportImagePicker(
                  images: _images,
                  onPickFromCamera: _pickImageFromCamera,
                  onPickFromGallery: _pickImageFromGallery,
                  onRemoveImage: _removeImage,
                  maxReached: _images.length >= maxImages,
                ),
              ),
              const SizedBox(height: 16),

              // FORM FIELDS
              ReportFormFields(
                titleController: _titleController,
                descController: _descController,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
                selectedLocation: _selectedLocation,
                onLocationChanged: (value) {
                  setState(() => _selectedLocation = value);
                },
                currentDate: _currentDate,
                categories: categories,
                locations: locations,
              ),

              const SizedBox(height: 24),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 27, 179, 115),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'Send Report',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// WIDGET: ReportImagePicker (same logic as before, just a separate class)

class ReportImagePicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final Function(int) onRemoveImage;
  final bool maxReached;

  const ReportImagePicker({
    super.key,
    required this.images,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemoveImage,
    required this.maxReached,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (images.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Text("No photo", style: TextStyle(color: Colors.grey)),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: SizedBox(
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: images.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              images[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => onRemoveImage(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              iconSize: 48,
              color: maxReached ? Colors.grey : Colors.blueGrey,
              onPressed: maxReached ? null : onPickFromCamera,
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.photo),
              iconSize: 48,
              color: maxReached ? Colors.grey : Colors.blueGrey,
              onPressed: maxReached ? null : onPickFromGallery,
            ),
          ],
        ),
        if (maxReached)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "You can upload up to 5 photos.",
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// WIDGET: ReportFormFields (fields: title, category, location, date display, desc)

class ReportFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  final String? selectedCategory;
  final String? selectedLocation;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onLocationChanged;

  final DateTime currentDate;
  final List<String> categories;
  final List<String> locations;

  const ReportFormFields({
    super.key,
    required this.titleController,
    required this.descController,
    required this.selectedCategory,
    required this.selectedLocation,
    required this.onCategoryChanged,
    required this.onLocationChanged,
    required this.currentDate,
    required this.categories,
    required this.locations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: "Title",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category
        DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: onCategoryChanged,
          items: buildDropdownItems(categories),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.dashboard),
            hintText: "Category",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Location
        DropdownButtonFormField<String>(
          value: selectedLocation,
          onChanged: onLocationChanged,
          items: buildDropdownItems(locations),
          menuMaxHeight: 395,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.location_on),
            hintText: "Location",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Date Display
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              DateFormat('dd/MM/yyyy').format(currentDate),
              style: const TextStyle(fontSize: 16),
            ),
            trailing: const Icon(Icons.lock_clock),
          ),
        ),
        const SizedBox(height: 16),

        // Description
        TextField(
          controller: descController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Description",
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
