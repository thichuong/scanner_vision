import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../models/cccd_scan_result.dart';

class ScannerService {
  late DocumentScanner _documentScanner;

  ScannerService() {
    _initScanner();
  }

  void _initScanner() {
    final options = DocumentScannerOptions(
      documentFormats: const {DocumentFormat.jpeg, DocumentFormat.pdf},
      mode: ScannerMode.full,
      pageLimit: 10,
      isGalleryImport: true,
    );
    _documentScanner = DocumentScanner(options: options);
  }

  Future<DocumentScanningResult?> scanDocument() async {
    try {
      final result = await _documentScanner.scanDocument();
      return result;
    } catch (e) {
      debugPrint('Error scanning document: $e');
      return null;
    }
  }

  Future<CCCDScanResult?> scanCCCD({List<String>? initialImages}) async {
    try {
      final currentImages = initialImages ?? <String>[];
      final remainingPages = 2 - currentImages.length;

      if (remainingPages <= 0) {
        // Already have 2 or more images, just validate
        return _validateImages(currentImages);
      }

      final options = DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        pageLimit: remainingPages,
        isGalleryImport: true,
      );
      final cccdScanner = DocumentScanner(options: options);
      final result = await cccdScanner.scanDocument();
      cccdScanner.close();

      final newImages = result.images;
      final totalImages = <String>[...currentImages, ...?newImages];

      if (totalImages.isEmpty) {
        return null;
      }

      return _validateImages(totalImages);
    } catch (e) {
      debugPrint('Error scanning CCCD: $e');
      return null;
    }
  }

  Future<CCCDScanResult> _validateImages(List<String> images) async {
    final barcodeScanner = BarcodeScanner();
    final faceDetector = FaceDetector(options: FaceDetectorOptions());

    String? qrData;
    bool hasFace = false;

    for (final imagePath in images) {
      final inputImage = InputImage.fromFilePath(imagePath);

      if (qrData == null) {
        final barcodes = await barcodeScanner.processImage(inputImage);
        for (Barcode barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          if (rawValue != null && rawValue.contains('|')) {
            qrData = rawValue;
            break;
          }
        }
      }

      if (!hasFace) {
        final faces = await faceDetector.processImage(inputImage);
        if (faces.isNotEmpty) {
          hasFace = true;
        }
      }
    }

    await barcodeScanner.close();
    await faceDetector.close();

    final bool isComplete = images.length >= 2 && qrData != null && hasFace;

    return CCCDScanResult(
      images: images,
      qrData: qrData,
      hasFace: hasFace,
      isComplete: isComplete,
    );
  }

  void dispose() {
    _documentScanner.close();
  }
}
