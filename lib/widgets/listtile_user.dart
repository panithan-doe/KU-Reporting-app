import 'dart:convert';
import 'package:flutter/material.dart';

class ListTileUser extends StatelessWidget {
  const ListTileUser({
    super.key,
    required this.docId,
    required this.image,
    required this.username,
    required this.name,
    required this.role,
  });

  final String docId;
  final String? image;
  final String username;
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
        height: 76,
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
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  height: 48,
                  width: 48,
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
                        username.length > 50
                            ? '${username.substring(0, 50)}...'
                            : username,
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
      child: const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  // Attempt to decode as Base64
  try {
    final decodedBytes = base64Decode(image!);
    // If decoding succeeds, show the MemoryImage
    return Image.memory(
      decodedBytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // If the MemoryImage fails for some reason, fallback
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        );
      },
    );
  } catch (e) {
    // Decoding as base64 failed:
    // - Maybe it's a direct URL to an image
    // - Or a local asset path like "assets/..."
    // Let's handle those:

    // // If it starts with "assets/", attempt to load an asset:
    // if (image!.startsWith('assets/')) {
    //   return Image.asset(
    //     image!,
    //     fit: BoxFit.cover,
    //     errorBuilder: (context, error, stackTrace) {
    //       return Container(
    //         color: Colors.grey[300],
    //         child: const Icon(Icons.person, color: Colors.white, size: 40),
    //       );
    //     },
    //   );
    // }

    // Otherwise, assume it's a network URL
    return Image.network(
      image!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.person, color: Colors.white, size: 40),
        );
      },
    );
  }
}

}