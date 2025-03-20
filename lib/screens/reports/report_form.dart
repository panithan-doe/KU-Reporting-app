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
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
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
              Center(child: ReportImagePicker(image: _image, onImagePicked: _pickImage)),
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
  final File? image;
  final VoidCallback onImagePicked;

  const ReportImagePicker({super.key, required this.image, required this.onImagePicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(image == null ? "No photo" : "Photo selected", style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: image != null ? FileImage(image!) : null,
              child: image == null ? const Icon(Icons.camera_alt, size: 30, color: Colors.white) : null,
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.photo_library, color: Colors.grey),
                onPressed: onImagePicked,
              ),
            ),
          ],
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
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: const [DropdownMenuItem(child: Text("Category"), value: "category")],
      onChanged: (value) {},
    );
  }

  Widget _buildLocationPicker(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: const Text("Add location"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text("Add date"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: "Description",
        border: OutlineInputBorder(),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send, color: Colors.white),
            SizedBox(width: 8),
            Text('Send Report', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}