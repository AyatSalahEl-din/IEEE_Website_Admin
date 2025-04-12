import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static Future<Uint8List?> pickImage() async {
    final pickedImage = await ImagePickerWeb.getImageAsBytes();
    return pickedImage;
  }
  
  static String generateUniqueFileName(String originalName) {
    // Get file extension
    final extension = originalName.split('.').last.toLowerCase();
    
    // Generate unique ID using UUID
    final uniqueId = const Uuid().v4();
    
    // Create a unique filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'project_${timestamp}_$uniqueId.$extension';
  }

  static Widget imagePreview(Uint8List? imageData, String? imageUrl, {double? width, double? height}) {
    if (imageData != null) {
      return Image.memory(
        imageData,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40),
          );
        },
      );
    } else {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 40),
      );
    }
  }
}