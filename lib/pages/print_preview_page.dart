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

              await Printing.layoutPdf(
                onLayout: (PdfPageFormat format) async => bytes,
                name: 'scanner_vision_${DateTime.now().millisecondsSinceEpoch}',
              );
            },
            icon: const Icon(Icons.print, size: 28),
            label: const Text('IN TÀI LIỆU', style: TextStyle(fontSize: 18)),
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
