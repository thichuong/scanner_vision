import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import '../models/scan_session.dart';
import '../models/cccd_model.dart';
import '../services/storage_service.dart';
import '../pdf_service.dart';
import '../settings_service.dart';
import 'print_preview_page.dart';

class SessionDetailPage extends StatefulWidget {
  final ScanSession session;

  const SessionDetailPage({super.key, required this.session});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late ScanSession _currentSession;

  @override
  void initState() {
    super.initState();
    _currentSession = widget.session;
  }

  void _copyToClipboard(CCCDModel model) {
    final text =
        '''Thông tin CCCD:
- Số CCCD: ${model.id}
- Số CMND cũ: ${model.oldId}
- Họ và Tên: ${model.fullName}
- Ngày sinh: ${model.dob}
- Giới tính: ${model.gender}
- Địa chỉ: ${model.address}
- Ngày cấp: ${model.issueDate}''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã copy thông tin vào Clipboard!')),
    );
  }

  void _openPrintPreview({required bool isVertical}) async {
    if (_currentSession.imagePaths.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không có ảnh để tạo PDF!')));
      return;
    }

    final showPreview = await SettingsService.shouldShowPreview();
    if (!mounted) return;
    if (showPreview) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrintPreviewPage(
              imagePaths: _currentSession.imagePaths,
              isCccd: _currentSession.type == 'cccd',
              isVertical: isVertical,
            ),
          ),
        );
      }
    } else {
      // Direct Save
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final Uint8List bytes;
        if (_currentSession.type == 'cccd') {
          bytes = await PdfService.generateCCCDPdfBytes(
            PdfPageFormat.a4,
            _currentSession.imagePaths,
            isVertical: isVertical,
          );
        } else {
          bytes = await PdfService.generateDocumentPdfBytes(
            PdfPageFormat.a4,
            _currentSession.imagePaths,
          );
        }

        String? saveFolder = await SettingsService.getSaveFolder();
        if (saveFolder == null || saveFolder.isEmpty) {
          saveFolder = '/storage/emulated/0/Download';
        }

        final filename =
            'ScannerVision_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('$saveFolder/$filename');
        if (!await file.parent.exists()) {
          await file.parent.create(recursive: true);
        }
        await file.writeAsBytes(bytes);

        if (mounted) {
          Navigator.pop(context); // close loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu PDF tại $saveFolder/$filename')),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // close loader
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi khi lưu PDF: $e')));
        }
      }
    }
  }

  void _deleteSession() async {
    await StorageService().deleteSession(_currentSession.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isCccd = _currentSession.type == 'cccd';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: Text(
              isCccd ? 'Chi tiết CCCD' : 'Chi tiết Tài liệu',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                onPressed: () => _deleteSession(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (isCccd)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                _openPrintPreview(isVertical: true),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('In PDF (Dọc)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _openPrintPreview(isVertical: false),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('In PDF (Ngang)'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _openPrintPreview(isVertical: true),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('XEM & IN PDF'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isCccd && _currentSession.cccdData != null)
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Số CCCD', _currentSession.cccdData!.id),
                      _buildInfoRow(
                        'Họ và Tên',
                        _currentSession.cccdData!.fullName,
                      ),
                      _buildInfoRow('Ngày sinh', _currentSession.cccdData!.dob),
                      _buildInfoRow(
                        'Giới tính',
                        _currentSession.cccdData!.gender,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        onPressed: () =>
                            _copyToClipboard(_currentSession.cccdData!),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Toàn Bộ Thông Tin'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final path = _currentSession.imagePaths[index];
                return GestureDetector(
                  onTap: () {
                    // TODO navigate to ImageFilterPage
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(path),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            alignment: Alignment.center,
                            child: Text(
                              'Ảnh ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: _currentSession.imagePaths.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
