import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../services/pdf_service.dart';

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
      appBar: AppBar(title: const Text('In & Lưu PDF'), centerTitle: true),
      body: PdfPreview(
        build: (format) async {
          if (isCccd) {
            return await PdfService.generateCCCDPdfBytes(
              format,
              imagePaths,
              isVertical: isVertical,
            );
          } else {
            return await PdfService.generateDocumentPdfBytes(
              format,
              imagePaths,
            );
          }
        },
        useActions: true,
        canChangeOrientation: true,
        canChangePageFormat: true,
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName:
            'scanner_vision_${DateTime.now().millisecondsSinceEpoch}.pdf',
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: FilledButton.icon(
            onPressed: () async {
              // Trigger printing manually since we want a big button
              final format = PdfPageFormat.a4;
              final bytes = isCccd
                  ? await PdfService.generateCCCDPdfBytes(
                    format,
                    imagePaths,
                    isVertical: isVertical,
                  )
                  : await PdfService.generateDocumentPdfBytes(
                    format,
                    imagePaths,
                  );

              final fileName =
                  'ScannerVision_${DateTime.now().millisecondsSinceEpoch}.pdf';
              final savedPath = await PdfService.saveAndCopyPdf(bytes, fileName);

              // Open the file immediately
              await PdfService.openFile(savedPath);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã lưu vào bộ nhớ và copy đường dẫn: $savedPath'),
                    backgroundColor: Colors.green,
                  ),
                );
              }

              // Removed Printing.layoutPdf as requested
            },
            icon: const Icon(Icons.picture_as_pdf, size: 28),
            label: const Text('LƯU & MỞ PDF', style: TextStyle(fontSize: 18)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
