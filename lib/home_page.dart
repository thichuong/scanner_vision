import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'scanner_service.dart';
import 'pdf_service.dart';
import 'models/cccd_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScannerService _scannerService = ScannerService();
  DocumentScanningResult? _latestResult;

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _scanDocument() async {
    final result = await _scannerService.scanDocument();
    if (result != null) {
      setState(() {
        _latestResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Vision', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 2,
      ),
      body: _buildBody(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'scan_doc',
            onPressed: _scanDocument,
            icon: const Icon(Icons.document_scanner),
            label: const Text('Scan Doc'),
          ),
          const SizedBox(width: 16),
          FloatingActionButton.extended(
            heroTag: 'scan_cccd',
            onPressed: _scanCCCD,
            icon: const Icon(Icons.credit_card),
            label: const Text('Scan CCCD'),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _scanCCCD() async {
    final result = await _scannerService.scanCCCD();
    if (result != null) {
      if (mounted) {
        _showCCCDDialog(result);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy thông tin CCCD hoặc mã QR!')),
        );
      }
    }
  }

  void _showCCCDDialog(CCCDModel model) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Thông tin CCCD',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        _buildInfoRow('Số CCCD', model.id),
                        _buildInfoRow('Số CMND cũ', model.oldId),
                        _buildInfoRow('Họ và Tên', model.fullName),
                        _buildInfoRow('Ngày sinh', model.dob),
                        _buildInfoRow('Giới tính', model.gender),
                        _buildInfoRow('Địa chỉ', model.address),
                        _buildInfoRow('Ngày cấp', model.issueDate),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(model),
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Thông Tin (Text)'),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _exportPdf(model, isVertical: true),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Lưu A4 (Dọc)'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _exportPdf(model, isVertical: false),
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('Lưu A4 (Ngang)'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _copyToClipboard(CCCDModel model) {
    final text = 'Thông tin CCCD:\n'
        '- Số CCCD: ${model.id}\n'
        '- Số CMND cũ: ${model.oldId}\n'
        '- Họ và Tên: ${model.fullName}\n'
        '- Ngày sinh: ${model.dob}\n'
        '- Giới tính: ${model.gender}\n'
        '- Địa chỉ: ${model.address}\n'
        '- Ngày cấp: ${model.issueDate}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy thông tin vào Clipboard!')),
    );
  }

  Future<void> _exportPdf(CCCDModel model, {required bool isVertical}) async {
    if (model.capturedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có ảnh để tạo PDF!')),
      );
      return;
    }
    try {
      final file = await PdfService.generateCCCDPdf(
        model.capturedImages,
        isVertical: isVertical,
      );
      await Share.shareXFiles([XFile(file.path)], text: 'CCCD PDF');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tạo PDF: $e')),
        );
      }
    }
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_latestResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'No documents scanned yet.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            const Text('Tap the scan button below to begin.'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_latestResult!.pdf != null)
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Generated PDF'),
              subtitle: Text('Pages: ${_latestResult!.pdf!.pageCount}'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () {
                  // TODO: Implement open or share PDF
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved at \n${_latestResult!.pdf!.uri}')),
                  );
                },
              ),
            ),
          ),
        if (_latestResult!.images != null && _latestResult!.images!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Scanned Images (${_latestResult!.images!.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _latestResult!.images!.length,
            itemBuilder: (context, index) {
              final imageUri = _latestResult!.images![index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(
                      File(imageUri),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                    ),
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        alignment: Alignment.center,
                        child: Text(
                          'Page ${index + 1}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ]
      ],
    );
  }
}
