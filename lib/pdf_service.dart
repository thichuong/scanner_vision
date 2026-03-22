import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<Uint8List> generateCCCDPdfBytes(
    PdfPageFormat format,
    List<String> imagePaths, {
    bool isVertical = true,
  }) async {
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

  static Future<File> generateCCCDPdf(
    List<String> imagePaths, {
    bool isVertical = true,
  }) async {
    final bytes = await generateCCCDPdfBytes(
      PdfPageFormat.a4,
      imagePaths,
      isVertical: isVertical,
    );
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/cccd_scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<Uint8List> generateDocumentPdfBytes(
    PdfPageFormat format,
    List<String> imagePaths,
  ) async {
    final pdf = pw.Document();

    for (var path in imagePaths) {
      final bytes = File(path).readAsBytesSync();
      final decodedImage = await decodeImageFromList(bytes);
      final isLandscape = decodedImage.width > decodedImage.height;

      // Force orientation based on image dimensions rather than what the UI (PdfPreview) provides
      // format.portrait ensures a portrait layout before we optionally call .landscape
      final pageFormat = isLandscape
          ? format.portrait.landscape
          : format.portrait;

      print('📸 --- KIỂM TRA KHỔ GIẤY --- 📸');
      print('Đường dẫn: $path');
      print(
        'Kích thước thật của ảnh: Rộng = ${decodedImage.width}, Cao = ${decodedImage.height}',
      );
      print(
        'Kết luận ảnh: ${isLandscape ? "NGANG (Landscape)" : "DỌC (Portrait)"}',
      );
      print(
        'Khổ PDF thiết lập: Rộng = ${pageFormat.width}, Cao = ${pageFormat.height}',
      );
      print('------------------------------');

      final img = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: format.portrait,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            pw.Widget child = pw.Image(img, fit: pw.BoxFit.contain);
            // Rotate 90 degrees if landscape to fit on portrait page
            if (isLandscape) {
              child = pw.Transform.rotateBox(
                angle: 1.5707963268, // pi/2 radians
                child: child,
              );
            }
            return pw.Center(child: child);
          },
        ),
      );
    }

    return pdf.save();
  }

  static Future<File> generateDocumentPdf(List<String> imagePaths) async {
    final bytes = await generateDocumentPdfBytes(PdfPageFormat.a4, imagePaths);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/doc_scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);
    return file;
  }
}
