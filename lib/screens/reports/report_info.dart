import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ku_report_app/services/notification_service.dart';
import 'package:ku_report_app/services/report_service.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class ReportInfo extends StatelessWidget {
  final String docId;

  const ReportInfo({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    // 1) Get the current user
    final user = FirebaseAuth.instance.currentUser;

    // If the user is somehow null, just show something
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No logged-in user found.')),
      );
    }

    // 2) FutureBuilder for user doc (which has the "role")
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('No user record found.')),
          );
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
        final userRole = userData['role'] as String? ?? 'User';

        // 3) Build the StreamBuilder for the specific report doc
        return Scaffold(
          backgroundColor: const Color(0xFFF2F5F7),
          appBar: GoBackAppBar(titleText: "Report info"),
          body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reports')
                .doc(docId)
                .snapshots(),
            builder: (context, reportSnapshot) {
              if (!reportSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = reportSnapshot.data!.data() as Map<String, dynamic>?;
              if (data == null) {
                return const Center(child: Text('No data found'));
              }

              // images
              final List<dynamic>? base64ImagesList =
                  data['images'] as List<dynamic>?;
              final List<String> base64Images = base64ImagesList != null
                  ? base64ImagesList.cast<String>()
                  : [];

              // Extract fields from the "reports" doc
              final title = data['title'] as String;
              final Timestamp? postDateTimestamp = data['postDate'] as Timestamp?;
              final postDateString = postDateTimestamp != null
                  ? DateFormat('dd-MM-yyyy').format(postDateTimestamp.toDate())
                  : '';
              final category = data['category'] as String;
              final status = data['status'] as String;
              final location = data['location'] as String;
              final description = data['description'] as String;
              final userId = data['userId'] as String;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ImageDetails(base64Images: base64Images),
                    const SizedBox(height: 20),

                    HeaderDetails(
                      title: title,
                      status: status,
                      postDate: postDateString,
                    ),
                    const SizedBox(height: 20),

                    BodyDetails(
                      category: category,
                      location: location,
                      description: description,
                    ),
                    const SizedBox(height: 20),

                    // If the current user is a "Technician", show action buttons
                    if (userRole == 'Technician') ...[
                      ChangeStatusButton(
                        docId: docId,
                        reportTitle: title,
                        status: status,
                        userId: userId,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// IMAGE SECTION:
class ImageDetails extends StatelessWidget {
  ImageDetails({
    super.key,
    required this.base64Images,
  });

  final List<String> base64Images;

  final PageController _pageController = PageController(viewportFraction: 0.4);

  @override
  Widget build(BuildContext context) {
    if (base64Images.isEmpty) {
      return const Center(
        child: Text('No images'),
      );
    }

    return SizedBox(
      height: 172,
      child: PageView.builder(
        controller: _pageController,
        itemCount: base64Images.length,
        itemBuilder: (context, index) {
          final base64Str = base64Images[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: _buildImage(base64Str),
          );
        },
      ),
    );
  }

  /// Decode the base64 string and return an Image.memory widget
  Widget _buildImage(String base64Str) {
    try {
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // If there's an error decoding or rendering, show placeholder
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.white),
          );
        },
      );
    } catch (e) {
      // If decoding fails for any reason, fallback
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.white),
      );
    }
  }
}

// HEADER SECTION:
class HeaderDetails extends StatelessWidget {
  const HeaderDetails({
    super.key,
    required this.title,
    required this.status,
    required this.postDate,
  });

  final String title;
  final String status;
  final String postDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            Container(
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: _statusColor(status),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('POST DATE: $postDate', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  /// Simple helper to color statuses
  Color _statusColor(String status) {
    switch (status) {
      case "In progress":
        return Colors.orange;
      case "Pending":
        return Colors.blue;
      case "Canceled":
        return Colors.red;
      case "Completed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// BODY SECTION:
class BodyDetails extends StatelessWidget {
  const BodyDetails({
    super.key,
    required this.category,
    required this.location,
    required this.description,
  });

  final String category;
  final String location;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category
        const Text(
          "CATEGORY:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 26,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Location
        const Text(
          "LOCATION:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 4),
                  Text(location),
                ],
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Description
        const Text(
          "DESCRIPTION:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8.0),
          height: 92,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.grey[300],
          ),
          child: Text(description),
        ),
      ],
    );
  }
}

/// This widget is only shown if userRole == 'Technician'
class ChangeStatusButton extends StatelessWidget {
  final String docId;
  final String reportTitle;
  final String status;
  final String userId;

  ChangeStatusButton({
    super.key,
    required this.docId,
    required this.reportTitle,
    required this.status,
    required this.userId,
  });

  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Pending':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // START WORK
            InkWell(
              onTap: () {
                _showConfirmationDialog(
                  context: context,
                  title: 'Are you sure to start work?',
                  subtitle:
                      'This work will be moved to "In progress". You can cancel or complete it later.',
                  yesButtonText: 'Start',
                  yesButtonColor: Colors.orange,
                  onYes: () {
                    _reportService.updateStatus(docId, 'In progress');
                    _notificationService.addNotification(
                      reportTitle,
                      'In progress',
                      userId,
                      docId,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.orange,
                ),
                child: const Center(
                  child: Text(
                    'Start Work',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // CANCEL WORK
            InkWell(
              onTap: () {
                _showConfirmationDialog(
                  context: context,
                  title: 'Are you sure to cancel work?',
                  subtitle:
                      'This work will be canceled, but you can come back to work any time.',
                  yesButtonText: 'Cancel',
                  yesButtonColor: Colors.red,
                  onYes: () {
                    _reportService.updateStatus(docId, 'Canceled');
                    _notificationService.addNotification(
                      reportTitle,
                      'Canceled',
                      userId,
                      docId,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'Cancel Work',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'In progress':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // COMPLETE WORK
            InkWell(
              onTap: () {
                _showConfirmationDialog(
                  context: context,
                  title: 'Are you sure to complete work?',
                  subtitle:
                      'This work will be marked as completed. You can still view or reopen if needed.',
                  yesButtonText: 'Complete',
                  yesButtonColor: Colors.green,
                  onYes: () {
                    _reportService.updateStatus(docId, 'Completed');
                    _notificationService.addNotification(
                      reportTitle,
                      'Completed',
                      userId,
                      docId,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.green,
                ),
                child: const Center(
                  child: Text(
                    'Complete Work',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // CANCEL WORK
            InkWell(
              onTap: () {
                _showConfirmationDialog(
                  context: context,
                  title: 'Are you sure to cancel work?',
                  subtitle:
                      'This work will be canceled, but you can come back any time.',
                  yesButtonText: 'Yes',
                  yesButtonColor: Colors.red,
                  onYes: () {
                    _reportService.updateStatus(docId, 'Canceled');
                    _notificationService.addNotification(
                      reportTitle,
                      'Canceled',
                      userId,
                      docId,
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'Cancel Work',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      case 'Completed':
        return InkWell(
          onTap: null, // disabled
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.green.shade100,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.check_circle, size: 32, color: Colors.green),
                ],
              ),
            ),
          ),
        );

      case 'Canceled':
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // "Canceled" - disabled
            InkWell(
              onTap: null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[400],
                ),
                child: const Center(
                  child: Text(
                    'Canceled',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // "Undo Cancellation"
            InkWell(
              onTap: () {
                _showConfirmationDialog(
                  context: context,
                  title: 'Are you sure to undo cancellation?',
                  subtitle:
                      'This work will be moved back to "In progress". You can still complete or cancel it later.',
                  yesButtonText: 'Undo',
                  yesButtonColor: Colors.red,
                  onYes: () {
                    // User specified "no notification" for undo,
                    // but you can add it if you want
                    _reportService.updateStatus(docId, 'In progress');
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Text(
                    'Undo Cancellation',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Generic helper function to show a confirmation dialog
  void _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String yesButtonText,
    required Color yesButtonColor,
    required VoidCallback onYes,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
          alignment: Alignment.center,

          title: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          content: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),

          actionsAlignment: MainAxisAlignment.center,
          actions: [
            // No button
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                minimumSize: const Size(100, 44),
                foregroundColor: Colors.grey,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx); // close the dialog
              },
              child: const Text('No'),
            ),
            const SizedBox(width: 12),
            // Yes button
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                minimumSize: const Size(100, 44),
                backgroundColor: yesButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx); // close the dialog
                onYes();            // perform the action
              },
              child: Text(yesButtonText),
            ),
          ],
        );
      },
    );
  }
}
