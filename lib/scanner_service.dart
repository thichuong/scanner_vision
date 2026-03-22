import 'package:flutter/foundation.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

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
      // Handle error accordingly
      debugPrint('Error scanning document: $e');
      return null;
    }
  }

  void dispose() {
    _documentScanner.close();
  }
}
