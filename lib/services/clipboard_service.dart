import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pasteboard/pasteboard.dart';

class ClipboardService {
  /// Copy images to the system clipboard.
  /// On mobile, usually only the last image is copied due to platform limitations.
  static Future<void> copyImagesToClipboard(List<String> imagePaths) async {
    debugPrint(
      'Starting copyImagesToClipboard with ${imagePaths.length} images: $imagePaths',
    );
    try {
      if (imagePaths.isEmpty) return;

      // Pasteboard on mobile supports one image at a time reliably
      final lastPath = imagePaths.last;
      final file = File(lastPath);

      if (!await file.exists()) {
        debugPrint('File does NOT exist: $lastPath');
        return;
      }

      final bytes = await file.readAsBytes();
      debugPrint('Read ${bytes.length} bytes from $lastPath');

      // Copy image bytes
      // Corrected method name for pasteboard 0.5.0
      await Pasteboard.writeImage(bytes);
      debugPrint('Pasteboard image write completed.');
    } catch (e) {
      debugPrint('Error copying images to clipboard: $e');
    }
  }

  /// Copy a single image to the system clipboard.
  static Future<void> copyImageToClipboard(String imagePath) async {
    await copyImagesToClipboard([imagePath]);
  }
}
