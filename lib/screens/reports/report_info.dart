import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ku_report_app/widgets/go_back_appbar.dart';

class ReportInfo extends StatelessWidget {
  const ReportInfo({super.key, required this.docId});

  final String docId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F5F7),
      appBar: GoBackAppBar(titleText: "Report info"),
      body: StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('reports')
                .doc(docId)
                .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text('No data found'));
          }

          final title = data['title'];
          final postDate = data['postDate'];
          final category = data['category'];
          final status = data['status'];
          final location = data['location'];
          final description = data['description'];

          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                ImageDetails(),
                SizedBox(height: 24),

                HeaderDetails(title: title, status: status, postDate: postDate),
                SizedBox(height: 24),

                BodyDetails(
                  category: category,
                  location: location,
                  description: description,
                ), // category, location, description
                SizedBox(height: 24),
                ChangeStatusButton(status: status),
              ],
            ),
          );
        },
      ),
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
      height: 180,
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

// BUTTON SECTION ()
class ChangeStatusButton extends StatelessWidget {
  const ChangeStatusButton({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    late Color backgroundButtonColor;
    late Color textButtonColor;

    switch (status) {
      case 'In progress':
        backgroundButtonColor = Colors.orange.shade100;
        textButtonColor = Colors.orange;
        break;
      case 'Pending':
        backgroundButtonColor = Colors.blue.shade100;
        textButtonColor = Colors.blue;
        break;
      case 'Canceled':
        backgroundButtonColor = Colors.red.shade100;
        textButtonColor = Colors.red;
        break;
      case 'Completed':
        backgroundButtonColor = Colors.green.shade100;
        textButtonColor = Colors.green;
        break;
      default:
        backgroundButtonColor = Colors.grey.shade200;
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
              Icon(
                Icons.check_circle,
                size: 32,
                color: textButtonColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
