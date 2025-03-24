import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';
import 'package:ku_report_app/screens/reports/report_success.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 3;

  String? _selectedCategory;
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // ไม่ต้อง set _currentDate อีก
  }

  Future<void> _pickImageFromGallery() async {
    if (_images.length >= maxImages) return;

    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final newImages = pickedFiles
          .take(maxImages - _images.length)
          .map((file) => File(file.path));
      setState(() {
        _images.addAll(newImages);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_images.length >= maxImages) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
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
              ReportFormFields(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                currentDate: _currentDate,
              ),
              const SizedBox(height: 24),
              const SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

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
              "You can upload up to 3 photos.",
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class ReportFormFields extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String?) onCategoryChanged;
  final DateTime currentDate;

  const ReportFormFields({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField("Title"),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: onCategoryChanged,
          decoration: InputDecoration(
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
          items: const [
            DropdownMenuItem(
              value: "ไฟฟ้า",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ไฟฟ้า", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ถนน",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ถนน", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อุปกรณ์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อุปกรณ์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อื่นๆ",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อื่นๆ", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildLocationPicker(context),
        const SizedBox(height: 16),
        _buildDateDisplay(currentDate),
        const SizedBox(height: 16),
        _buildDescriptionField(),
      ],
    );
  }

  Widget _buildDateDisplay(DateTime date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
          DateFormat('dd/MM/yyyy').format(date),
          style: const TextStyle(fontSize: 16),
        ),
        trailing: const Icon(Icons.lock_clock),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
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
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: const Text("Add location"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
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
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ReportSuccessScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 27, 179, 115),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Send Report', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
