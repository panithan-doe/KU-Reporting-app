import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 3;

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
              const ReportFormFields(),
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
                child: ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
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
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        )
                      ],
                    );
                  },
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
  const ReportFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField("Title"),
        const SizedBox(height: 16),
        _buildDropdownField("Category"),
        const SizedBox(height: 16),
        _buildLocationPicker(context),
        const SizedBox(height: 16),
        _buildDatePicker(context),
        const SizedBox(height: 16),
        _buildDescriptionField(),
      ],
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: const [
        DropdownMenuItem(child: Text("Category"), value: "category"),
      ],
      onChanged: (value) {},
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

  Widget _buildDatePicker(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: const Text("Add date"),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.send, color: Colors.white),
        label: const Text('Send Report', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
