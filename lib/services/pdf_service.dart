import 'dart:io';
// import 'dart:typed_data'; // Provided by services.dart
import 'package:flutter/painting.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'settings_service.dart';

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

      final img = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          pageFormat: format.portrait,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            final pageWidth = format.portrait.width;
            final pageHeight = format.portrait.height;

            double imgWidth = decodedImage.width.toDouble();
            double imgHeight = decodedImage.height.toDouble();

            double targetWidth = isLandscape ? pageHeight : pageWidth;
            double targetHeight = isLandscape ? pageWidth : pageHeight;

            // Tính toán tỷ lệ (scale) để fit hoàn toàn vào trang mà không bị tràn (tương đương contain)
            double scaleX = targetWidth / imgWidth;
            double scaleY = targetHeight / imgHeight;
            double scale = scaleX < scaleY ? scaleX : scaleY;

            double finalWidth = imgWidth * scale;
            double finalHeight = imgHeight * scale;

            if (isLandscape) {
              return pw.Center(
                child: pw.Transform.rotateBox(
                  angle: 1.5707963268, // pi/2 radians
                  unconstrained: true, // ignore portrait parent constraints before rotating
                  child: pw.Container(
                    width: finalWidth, // dùng kích thước đã tính toán chính xác
                    height: finalHeight,
                    child: pw.Image(img, fit: pw.BoxFit.fill),
                  ),
                ),
              );
            } else {
              return pw.Center(
                child: pw.Container(
                  width: finalWidth,
                  height: finalHeight,
                  child: pw.Image(img, fit: pw.BoxFit.fill),
                ),
              );
            }
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

  static Future<String> saveAndCopyPdf(Uint8List bytes, String fileName) async {
    String? saveFolder = await SettingsService.getSaveFolder();
    if (saveFolder == null || saveFolder.isEmpty) {
      if (Platform.isAndroid) {
        saveFolder = '/storage/emulated/0/Download';
      } else {
        final dir = await getDownloadsDirectory();
        saveFolder =
            dir?.path ?? (await getApplicationDocumentsDirectory()).path;
      }
    }

    final file = File('$saveFolder/$fileName');
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsBytes(bytes);

    // Copy path to clipboard if enabled
    if (await SettingsService.shouldSavePdfPathToClipboard()) {
      await Clipboard.setData(ClipboardData(text: file.path));
    }

    return file.path;
  }

  static Future<void> openFile(String path) async {
    await OpenFilex.open(path);
  }
}
