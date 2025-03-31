import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ku_report_app/screens/reports/report_info.dart';

class ListTileReport extends StatelessWidget {
  const ListTileReport({
    super.key,
    required this.docId,
    required this.images,
    required this.title,
    required this.location,
    required this.status,
    required this.category,
    required this.postDate,
  });

  final String docId;
  final String images;
  final String title;
  final String location;
  final String status;
  final String category;
  final String postDate;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportInfo(docId: docId)),
        );
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Leading + Title + Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: _buildLeadingImage(images),
                    ),
                  ),

                  SizedBox(width: 14),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title
                      Text(
                        title.length > 18
                            ? '${title.substring(0, 18)}...'
                            : title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Subtitle
                      Text(
                        location.length < 18
                            ? location
                            : '${location.substring(0, 18)}...',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),

              // End of list
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Status
                  Text(
                    status,
                    style: TextStyle(
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
                  ),
                  // Post Date
                  Text(
                    'Post date: $postDate',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to decode base64 or show a placeholder
  Widget _buildLeadingImage(String base64Str) {
    if (base64Str.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.photo, color: Colors.white),
      );
    }

    try {
      final bytes = base64Decode(base64Str);
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.white),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.white),
      );
    }
  }
}
