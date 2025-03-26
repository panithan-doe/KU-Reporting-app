// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:ku_report_app/widgets/go_back_appbar.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
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

        // 3) Now that we have userRole, build the StreamBuilder for the report
        return Scaffold(
          backgroundColor: const Color(0xFFF2F5F7),
          appBar: GoBackAppBar(titleText: "Report info"),
          body: StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
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

              // Extract fields from the "reports" doc
              final title = data['title'] as String;
              final postDate = data['postDate'] as String;
              final category = data['category'] as String;
              final status = data['status'] as String;
              final location = data['location'] as String;
              final description = data['description'] as String;
              final userId = data['userId'] as String;

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    ImageDetails(),
                    const SizedBox(height: 20),

                    HeaderDetails(
                      title: title,
                      status: status,
                      postDate: postDate,
                    ),
                    const SizedBox(height: 20),

                    BodyDetails(
                      category: category,
                      location: location,
                      description: description,
                    ),
                    const SizedBox(height: 20),

                    // // If the current user is a normal "User":
                    // if (userRole == 'User' || userRole == 'Admin') ...[
                    //   BottomStatusContainer(status: status),
                    // ],

                    // If the current user is a "Technician":
                    if (userRole == 'Technician') ...[
                      ChangeStatusButton(docId: docId, reportTitle: title, status: status, userId: userId),
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
  ImageDetails({super.key});

  final PageController _pageController = PageController(viewportFraction: 0.4);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.amber,
      height: 172,
      child: PageView(
        controller: _pageController,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              'assets/images/lecturehall3.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              'assets/images/lecturehall3.png',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              'assets/images/lecturehall3.png',
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),

            Container(
              height: 26,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color:
                    status == "In progress"
                        ? Colors.orange
                        : status == "Pending"
                        ? Colors.blue
                        : status == "Canceled"
                        ? Colors.red
                        : status == "Completed"
                        ? Colors.green
                        : Colors.grey,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text('POST DATE: $postDate', style: TextStyle(color: Colors.grey)),
      ],
    );
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
        Text(
          "CATEGORY:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Container(
              height: 26,
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.grey[300],
              ),
              child: Center(
                child: Text(
                  category,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Location
        Text(
          "LOCATION:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
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
                  Icon(Icons.location_on_outlined),
                  SizedBox(width: 4),
                  Text(location),
                ],
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Description
        Text(
          "DESCRIPTION:",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(8.0),
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

class BottomStatusContainer extends StatelessWidget {
  const BottomStatusContainer({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late Color backgroundButtonColor;
    late Color textButtonColor;

    switch (status) {
      case 'In progress':
        backgroundButtonColor = Colors.orange;
        break;
      case 'Pending':
        backgroundButtonColor = Colors.blue;
        break;
      case 'Canceled':
        backgroundButtonColor = Colors.red;
        break;
      case 'Completed':
        backgroundButtonColor = Colors.green;
        break;
      default:
        backgroundButtonColor = Colors.grey;
        textButtonColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: backgroundButtonColor,
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text
            Text(
              status,
              style: TextStyle(
                color: textButtonColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            // Icon if completed
            if (status == 'Completed') ...[
              SizedBox(width: 4),
              Icon(Icons.check_circle, size: 32, color: textButtonColor),
            ],
          ],
        ),
      ),
    );
  }
}

class ChangeStatusButton extends StatelessWidget {
  final String docId;
  final String reportTitle;
  final String status;
  final String userId;

  ChangeStatusButton({super.key, required this.docId, required this.reportTitle, required this.status, required this.userId});

  final ReportService _reportService = ReportService();
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    late Color backgroundButtonColor;
    late String updatedStatus;

    switch (status) {
      case 'Pending':
        backgroundButtonColor = Colors.orange;
        updatedStatus = 'In progress';
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                _reportService.updateStatus(docId, updatedStatus);
                _notificationService.addNotification(reportTitle, updatedStatus, userId, docId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: backgroundButtonColor,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Start Work',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                _reportService.updateStatus(docId, 'Canceled');
                _notificationService.addNotification(reportTitle, 'Canceled', userId, docId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Cancel Work',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case 'In progress':
        backgroundButtonColor = Colors.green;
        updatedStatus = 'Completed';
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                _reportService.updateStatus(docId, updatedStatus);
                _notificationService.addNotification(reportTitle, updatedStatus, userId, docId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: backgroundButtonColor,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Complete Work',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              onTap: () {
                _reportService.updateStatus(docId, 'Canceled');
                _notificationService.addNotification(reportTitle, 'Canceled', userId, docId);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Cancel Work',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case 'Completed':
        backgroundButtonColor = Colors.green.shade100;
        return InkWell(
          onTap: null, // disabled
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: backgroundButtonColor,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text
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
        backgroundButtonColor = Colors.red.shade100;
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.grey[400],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Canceled',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            InkWell(
              // change 'Canceled' to 'In progress' should not create 'checked notification'
              onTap: () => _reportService.updateStatus(docId, 'In progress'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 56,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      Text(
                        'Undo Cancellation',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
}
