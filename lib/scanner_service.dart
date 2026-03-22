import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'models/cccd_model.dart';

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

  Future<CCCDModel?> scanCCCD() async {
    try {
      final options = DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        pageLimit: 2, // Quét tối đa 2 mặt
        isGalleryImport: true,
      );
      final cccdScanner = DocumentScanner(options: options);
      final result = await cccdScanner.scanDocument();
      cccdScanner.close();

      final images = result.images;
      if (images == null || images.isEmpty) {
        return null;
      }

      final barcodeScanner = BarcodeScanner();

      // Duyệt qua tất cả các ảnh đã quét (có thể là 1 hoặc 2 mặt)
      for (final imagePath in images) {
        final inputImage = InputImage.fromFilePath(imagePath);
        final barcodes = await barcodeScanner.processImage(inputImage);

        for (Barcode barcode in barcodes) {
          final String? rawValue = barcode.rawValue;
          if (rawValue != null && rawValue.contains('|')) {
            await barcodeScanner.close();
            return CCCDModel.fromQR(rawValue, images: images);
          }
        }
      }

      await barcodeScanner.close();
      return null;
    } catch (e) {
      debugPrint('Error scanning CCCD: $e');
      return null;
    }
  }

  void dispose() {
    _documentScanner.close();
  }
}
