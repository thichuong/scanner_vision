import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  static Future<File> generateCCCDPdf(List<String> imagePaths, {bool isVertical = true}) async {
    final pdf = pw.Document();

    final images = imagePaths.map((path) {
      final bytes = File(path).readAsBytesSync();
      return pw.MemoryImage(bytes);
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
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

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/cccd_scan_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
