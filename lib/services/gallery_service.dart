import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';

class GalleryService {
  /// Save a list of images to the system gallery.
  static Future<void> saveImagesToGallery(List<String> imagePaths) async {
    debugPrint('Starting saveImagesToGallery with ${imagePaths.length} images');
    try {
      if (imagePaths.isEmpty) return;

      // Check for permission first
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        debugPrint('Requesting gallery access...');
        hasAccess = await Gal.requestAccess();
      }

      if (!hasAccess) {
        debugPrint('Gallery access denied');
        return;
      }

      // Save each image
      for (final path in imagePaths) {
        await Gal.putImage(path);
        debugPrint('Saved to gallery: $path');
      }

      debugPrint('All images saved to gallery successfully.');
    } catch (e) {
      debugPrint('Error saving images to gallery: $e');
    }
  }

  /// Save a single image to the system gallery.
  static Future<void> saveImageToGallery(String imagePath) async {
    await saveImagesToGallery([imagePath]);
  }
}
