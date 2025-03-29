import 'dart:convert';
import 'package:flutter/material.dart';

class ListTileUser extends StatelessWidget {
  const ListTileUser({
    super.key,
    required this.docId,
    required this.image,
    required this.name,
    required this.role,
  });

  final String docId;
  final String? image;
  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => UserInfo(docId: docId)),
        // );
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
              // Leading
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: _buildImage(),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Title
                      Text(
                        name.length > 50
                            ? '${name.substring(0, 50)}...'
                            : name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Subtitle
                      Text(
                        role,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    // If no image is provided, show a default person icon
    if (image == null || image!.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.white, size: 40),
      );
    }

    try {
      // Try to decode as base64
      if (image!.contains('base64')) {
        return Image.memory(
          base64Decode(image!.split(',').last),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.white, size: 40),
            );
          },
        );
      }
      
      // If it's an asset path
      if (image!.startsWith('assets/')) {
        return Image.asset(
          image!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: Icon(Icons.person, color: Colors.white, size: 40),
            );
          },
        );
      }
      
      // If it's a network image
      return Image.network(
        image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.person, color: Colors.white, size: 40),
          );
        },
      );
    } catch (e) {
      // If any error occurs, show default icon
      return Container(
        color: Colors.grey[300],
        child: Icon(Icons.person, color: Colors.white, size: 40),
      );
    }
  }
}