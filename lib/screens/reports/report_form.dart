import 'dart:io';
import 'dart:convert'; // สำหรับแปลงเป็น base64
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ลบ import เดิมของ report_success.dart ออก
// import 'package:ku_report_app/screens/reports/report_success.dart';

// เพิ่ม import MyReportsPage เข้ามา
import 'package:ku_report_app/screens/reports/my_reports.dart';

import 'package:ku_report_app/widgets/go_back_appbar.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({Key? key}) : super(key: key);

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  static const int maxImages = 5;

  String? _selectedCategory;
  String? _selectedLocation;
  final DateTime _currentDate = DateTime.now();

  // Controller สำหรับ title และ description
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _submitReport() async {
    // แปลงรูปภาพที่เลือกเป็น base64
    List<String> base64Images = [];
    for (File image in _images) {
      final bytes = await image.readAsBytes();
      base64Images.add(base64Encode(bytes));
    }

    // ดึง userId จาก FirebaseAuth
    final user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? 'unknown';

    // เตรียมข้อมูล report
    final reportData = {
      'category': _selectedCategory,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'images': base64Images,
      'location': _selectedLocation,
      'postDate': _currentDate,
      'status': 'Pending',
      'userId': userId,
    };

    // บันทึกข้อมูลลงใน Firestore
    await FirebaseFirestore.instance.collection('reports').add(reportData);

    // เปลี่ยนหน้าไปยัง MyReportsPage หลังจากส่ง report
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyReportsPage()),
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
                titleController: _titleController,
                descriptionController: _descriptionController,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                selectedLocation: _selectedLocation,
                onLocationChanged: (value) {
                  setState(() {
                    _selectedLocation = value;
                  });
                },
                currentDate: _currentDate,
              ),
              const SizedBox(height: 24),
              SubmitButton(onSubmit: _submitReport),
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
    Key? key,
    required this.images,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemoveImage,
    required this.maxReached,
  }) : super(key: key);

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

class ReportFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final String? selectedLocation;
  final void Function(String?) onCategoryChanged;
  final void Function(String?) onLocationChanged;
  final DateTime currentDate;

  const ReportFormFields({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.selectedLocation,
    required this.onLocationChanged,
    required this.currentDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTextField("Title", titleController),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          onChanged: onCategoryChanged,
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
          items: const [
            DropdownMenuItem(
              value: "ไฟฟ้า",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ไฟฟ้า", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ประปา",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ประปา", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อุปกรณ์ไฟฟ้า",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อุปกรณ์ไฟฟ้า", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "โครงสร้างและอาคาร",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("โครงสร้างและอาคาร", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ไอที",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ไอที", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ระบบความปลอดภัย",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ระบบความปลอดภัย", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "เฟอร์นิเจอร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("เฟอร์นิเจอร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "พื้นที่ภายนอกอาคาร",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("พื้นที่ภายนอกอาคาร", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: selectedLocation,
          onChanged: onLocationChanged,
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
          menuMaxHeight: 395,
          items: const [
            DropdownMenuItem(
              value: "คณะเกษตร",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะเกษตร", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะบริหารธุรกิจ",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะบริหารธุรกิจ", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะประมง",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะประมง", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะมนุษยศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะมนุษยศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะเศรษฐศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะเศรษฐศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะวิทยาศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะวิทยาศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะวิศวกรรมศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะวิศวกรรมศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะวนศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะวนศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะศึกษาศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะศึกษาศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะสังคมศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะสังคมศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะสัตวแพทยศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะสัตวแพทยศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะสิ่งแวดล้อม",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะสิ่งแวดล้อม", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "คณะสถาปัตยกรรมศาสตร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("คณะสถาปัตยกรรมศาสตร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "บัณฑิตวิทยาลัย",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("บัณฑิตวิทยาลัย", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "วิทยาลัยสิ่งแวดล้อม",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("วิทยาลัยสิ่งแวดล้อม", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "วิทยาลัยเทคนิคการสัตวแพทย์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("วิทยาลัยเทคนิคการสัตวแพทย์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารศูนย์เรียนรวม 1",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารศูนย์เรียนรวม 1", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารศูนย์เรียนรวม 2",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารศูนย์เรียนรวม 2", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารศูนย์เรียนรวม 3",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารศูนย์เรียนรวม 3", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารศูนย์เรียนรวม 4",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารศูนย์เรียนรวม 4", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "หอประชุมใหญ่",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("หอประชุมใหญ่", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "หอสมุด มก.",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("หอสมุด มก.", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สำนักบริการคอมพิวเตอร์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สำนักบริการคอมพิวเตอร์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ศูนย์หนังสือ มก.",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ศูนย์หนังสือ มก.", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารสารนิเทศ 50 ปี",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารสารนิเทศ 50 ปี", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารจักรพันธ์เพ็ญศิริ",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารจักรพันธ์เพ็ญศิริ", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคารเทพศาสตร์สถิตย์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคารเทพศาสตร์สถิตย์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคาร KU Home",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคาร KU Home", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "โรงอาหารกลาง 1",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("โรงอาหารกลาง 1", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "โรงอาหารกลาง 2",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("โรงอาหารกลาง 2", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สนามอินทรีจันทรสถิตย์",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สนามอินทรีจันทรสถิตย์", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สำนักการกีฬา",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สำนักการกีฬา", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สหกรณ์ร้านค้า มก.",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สหกรณ์ร้านค้า มก.", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สหกรณ์ออมทรัพย์ มก",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สหกรณ์ออมทรัพย์ มก", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "สถานพยาบาล มก.",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("สถานพยาบาล มก.", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ศูนย์วิจัยและควบคุมศัตรูพืชฯ",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ศูนย์วิจัยและควบคุมศัตรูพืชฯ", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "อาคาร KU-Green",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("อาคาร KU-Green", style: TextStyle(fontSize: 18)),
              ),
            ),
            DropdownMenuItem(
              value: "ศูนย์การศึกษานานาชาติ",
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("ศูนย์การศึกษานานาชาติ", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateDisplay(currentDate),
        const SizedBox(height: 16),
        _buildDescriptionField(descriptionController),
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
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

  Widget _buildDescriptionField(TextEditingController controller) {
    return TextField(
      controller: controller,
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
  final VoidCallback onSubmit;
  const SubmitButton({Key? key, required this.onSubmit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSubmit,
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