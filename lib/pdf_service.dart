import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<Uint8List> generateCCCDPdfBytes(PdfPageFormat format, List<String> imagePaths, {bool isVertical = true}) async {
    final pdf = pw.Document();

    final images = imagePaths.map((path) {
      final bytes = File(path).readAsBytesSync();
      return pw.MemoryImage(bytes);
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final children = images.map((img) {
            return pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Image(img, fit: pw.BoxFit.contain),
              ),
            );
          }).toList();

          return pw.Center(
            child: isVertical
                ? pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: children,
                  )
                : pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: children,
                  ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<File> generateCCCDPdf(List<String> imagePaths, {bool isVertical = true}) async {
    final bytes = await generateCCCDPdfBytes(PdfPageFormat.a4, imagePaths, isVertical: isVertical);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cccd_scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<Uint8List> generateDocumentPdfBytes(PdfPageFormat format, List<String> imagePaths) async {
    final pdf = pw.Document();

    for (var path in imagePaths) {
      final bytes = File(path).readAsBytesSync();
      final img = pw.MemoryImage(bytes);
      
      pdf.addPage(
        pw.Page(
          pageFormat: format,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Center(
               child: pw.Image(img, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<File> generateDocumentPdf(List<String> imagePaths) async {
    final bytes = await generateDocumentPdfBytes(PdfPageFormat.a4, imagePaths);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/doc_scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }
}
