import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../pdf_service.dart';

class PrintPreviewPage extends StatelessWidget {
  final List<String> imagePaths;
  final bool isCccd;
  final bool isVertical;
  
  const PrintPreviewPage({
    super.key,
    required this.imagePaths,
    required this.isCccd,
    this.isVertical = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In & Lưu PDF'),
        centerTitle: true,
      ),
      body: PdfPreview(
        build: (format) async {
          if (isCccd) {
            return await PdfService.generateCCCDPdfBytes(format, imagePaths, isVertical: isVertical);
          } else {
            return await PdfService.generateDocumentPdfBytes(format, imagePaths);
          }
        },
        useActions: true,
        canChangeOrientation: true,
        canChangePageFormat: true,
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: 'scanner_vision_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
    );
  }
}
