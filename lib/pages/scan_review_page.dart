import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pdf/pdf.dart';
import '../models/scan_session.dart';
import '../services/storage_service.dart';
import '../pdf_service.dart';
import '../settings_service.dart';
import 'print_preview_page.dart';

class ScanReviewPage extends StatefulWidget {
  final ScanSession session;
  final bool isEmbedded;
  final VoidCallback? onScanMore;
  final VoidCallback? onDone;
  final VoidCallback? onCancel;

  const ScanReviewPage({
    super.key,
    required this.session,
    this.isEmbedded = false,
    this.onScanMore,
    this.onDone,
    this.onCancel,
  });

  @override
  State<ScanReviewPage> createState() => _ScanReviewPageState();
}

class _ScanReviewPageState extends State<ScanReviewPage> {
  bool _isSaving = false;

  Future<void> _exportPdf() async {
    final showPreview = await SettingsService.shouldShowPreview();
    if (!mounted) return;

    if (showPreview) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrintPreviewPage(
            imagePaths: widget.session.imagePaths,
            isCccd: widget.session.type == 'cccd',
            isVertical: true,
          ),
        ),
      );
      // After preview, if we are embedded and the user wants to be done, we could call onDone.
      // But usually export handles its own flow.
    } else {
      setState(() => _isSaving = true);
      try {
        final Uint8List bytes;
        if (widget.session.type == 'cccd') {
          bytes = await PdfService.generateCCCDPdfBytes(
            PdfPageFormat.a4,
            widget.session.imagePaths,
            isVertical: true,
          );
        } else {
          bytes = await PdfService.generateDocumentPdfBytes(
            PdfPageFormat.a4,
            widget.session.imagePaths,
          );
        }

        final fileName =
            'ScannerVision_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final savedPath = await PdfService.saveAndCopyPdf(bytes, fileName);
        
        // Open the file immediately
        await PdfService.openFile(savedPath);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã lưu và copy đường dẫn: $savedPath'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.isEmbedded && widget.onDone != null) {
            widget.onDone!();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xuất PDF: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveToHistory() async {
    setState(() => _isSaving = true);
    try {
      await StorageService().saveSession(widget.session);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu vào lịch sử!'),
            backgroundColor: Colors.green,
          ),
        );
        if (widget.isEmbedded && widget.onDone != null) {
          widget.onDone!();
        } else {
          Navigator.pop(context, true); // Return true to indicate saved
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra kết quả'),
        leading: widget.isEmbedded
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onCancel,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.session.imagePaths.isEmpty
                ? const Center(child: Text('Không có hình ảnh nào được quét.'))
                : PageView.builder(
                    itemCount: widget.session.imagePaths.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.black26,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(widget.session.imagePaths[index]),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ).animate().fade(duration: 500.ms).scale(
                              begin: const Offset(0.9, 0.9),
                              curve: Curves.easeOutBack,
                            ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.session.imagePaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Vuốt để xem tất cả ${widget.session.imagePaths.length} trang',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Builder(
                  builder: (context) {
                    final isCccd = widget.session.type == 'cccd';
                    final isPartialCccd = isCccd && widget.session.imagePaths.length < 2;
                    
                    if (isPartialCccd) {
                      return ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () {
                                if (widget.isEmbedded &&
                                    widget.onScanMore != null) {
                                  widget.onScanMore!();
                                } else {
                                  Navigator.pop(context, 'scanMore');
                                }
                              },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('TIẾP THEO (QUÉT MẶT 2)'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      );
                    }
                    
                    return ElevatedButton.icon(
                      onPressed: _isSaving ? null : _exportPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('XUẤT PDF NGAY'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: colorScheme.primaryContainer,
                        foregroundColor: colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ).animate().slideY(begin: 0.2, duration: 400.ms).fade(),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveToHistory,
                  icon: const Icon(Icons.history),
                  label: const Text('LƯU VÀO LỊCH SỬ'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ).animate().slideY(begin: 0.3, duration: 500.ms).fade(),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isSaving
                      ? null
                      : (widget.isEmbedded && widget.onCancel != null
                          ? widget.onCancel
                          : () => Navigator.pop(context)),
                  child: const Text('Hủy bỏ'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
