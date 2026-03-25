import 'dart:io';
// import 'dart:typed_data'; // Provided by services.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:ui' as ui;
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
    List<String> imagePaths, {
    bool isLandscape = false,
    int imagesPerPage = 1,
    double imageScale = 1.0,
    bool isVerticalLayout = true,
    bool autoRotate = false,
  }) async {
    final pdf = pw.Document();

    // Group images according to imagesPerPage
    for (var i = 0; i < imagePaths.length; i += imagesPerPage) {
      final chunk = imagePaths.sublist(
        i,
        i + imagesPerPage > imagePaths.length
            ? imagePaths.length
            : i + imagesPerPage,
      );

      final images = <pw.MemoryImage>[];
      final dimensions = <ui.Size>[];

      for (var path in chunk) {
        final bytes = File(path).readAsBytesSync();
        images.add(pw.MemoryImage(bytes));

        if (autoRotate && imagesPerPage == 1) {
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          dimensions.add(
            ui.Size(
              frame.image.width.toDouble(),
              frame.image.height.toDouble(),
            ),
          );
        }
      }

      PdfPageFormat currentPageFormat;
      if (autoRotate && imagesPerPage == 1 && dimensions.isNotEmpty) {
        final imgSize = dimensions[0];
        // If image is wider than tall, use landscape if format is portrait, or vice versa
        if (imgSize.width > imgSize.height) {
          currentPageFormat = format.landscape;
        } else {
          currentPageFormat = format.portrait;
        }
      } else {
        currentPageFormat = isLandscape ? format.landscape : format.portrait;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: currentPageFormat,
          margin: const pw.EdgeInsets.all(10),
          build: (pw.Context context) {
            if (imagesPerPage == 1) {
              return pw.Center(
                child: pw.Container(
                  width: currentPageFormat.availableWidth * imageScale,
                  height: currentPageFormat.availableHeight * imageScale,
                  child: pw.Image(images[0], fit: pw.BoxFit.contain),
                ),
              );
            }

            // Grid calculation for N-up
            int crossAxisCount;
            int mainAxisCount;

            if (imagesPerPage == 2) {
              crossAxisCount =
                  currentPageFormat.width > currentPageFormat.height ? 2 : 1;
              mainAxisCount = currentPageFormat.width > currentPageFormat.height
                  ? 1
                  : 2;
            } else if (imagesPerPage == 4) {
              crossAxisCount = 2;
              mainAxisCount = 2;
            } else if (imagesPerPage == 6) {
              crossAxisCount =
                  currentPageFormat.width > currentPageFormat.height ? 3 : 2;
              mainAxisCount = currentPageFormat.width > currentPageFormat.height
                  ? 2
                  : 3;
            } else if (imagesPerPage == 9) {
              crossAxisCount = 3;
              mainAxisCount = 3;
            } else {
              crossAxisCount = 1;
              mainAxisCount = 1;
            }

            // Swap if orientation requires it
            if (!isVerticalLayout) {
              final temp = crossAxisCount;
              crossAxisCount = mainAxisCount;
              mainAxisCount = temp;
            }

            final gridChildren = images.map((img) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Center(
                  child: pw.Container(
                    width:
                        (currentPageFormat.availableWidth / crossAxisCount) *
                        imageScale,
                    height:
                        (currentPageFormat.availableHeight / mainAxisCount) *
                        imageScale,
                    child: pw.Image(img, fit: pw.BoxFit.contain),
                  ),
                ),
              );
            }).toList();

            return pw.GridView(
              crossAxisCount: crossAxisCount,
              children: gridChildren,
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
