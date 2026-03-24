import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import '../services/pdf_service.dart';
import '../providers/settings_provider.dart';

class PrintPreviewPage extends StatefulWidget {
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
  State<PrintPreviewPage> createState() => _PrintPreviewPageState();
}

class _PrintPreviewPageState extends State<PrintPreviewPage> {
  late bool _isLandscape;
  int _imagesPerPage = 1;
  double _imageScale = 1.0;
  bool _isVerticalLayout = true;
  bool _autoRotate = true;
  bool _autoScale = true;

  @override
  void initState() {
    super.initState();
    _isLandscape = !widget.isVertical;
    
    // Initialize from settings
    final settings = context.read<SettingsProvider>();
    _autoRotate = settings.autoRotate;
    _autoScale = settings.autoScale;
    
    if (_autoScale) {
      _imageScale = 1.5;
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cấu hình in & lưu',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      // Auto Toggles
                      SwitchListTile(
                        title: const Text('Tự động xoay (Auto-rotate)'),
                        subtitle: const Text('Tự động chọn hướng Dọc/Ngang theo ảnh'),
                        value: _autoRotate,
                        onChanged: (value) {
                          setState(() => _autoRotate = value);
                          context.read<SettingsProvider>().setAutoRotate(value);
                          setModalState(() {});
                        },
                      ),
                      SwitchListTile(
                        title: const Text('Tự động thu phóng (Auto-scale)'),
                        subtitle: const Text('Tự động khớp ảnh với trang'),
                        value: _autoScale,
                        onChanged: (value) {
                          setState(() {
                            _autoScale = value;
                            if (value) _imageScale = 1.5;
                          });
                          context.read<SettingsProvider>().setAutoScale(value);
                          setModalState(() {});
                        },
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      // Orientation
                      if (!_autoRotate || _imagesPerPage > 1) ...[
                        _buildSectionTitle('Hướng giấy (Thủ công)'),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text('Dọc'),
                              icon: Icon(Icons.portrait),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text('Ngang'),
                              icon: Icon(Icons.landscape),
                            ),
                          ],
                          selected: {_isLandscape},
                          onSelectionChanged: (value) {
                            setState(() => _isLandscape = value.first);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Images per page
                      _buildSectionTitle('Số ảnh trên 1 trang'),
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 4, 6, 9].map((count) {
                          final isSelected = _imagesPerPage == count;
                          return ChoiceChip(
                            label: Text('$count ảnh'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _imagesPerPage = count);
                                setModalState(() {});
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      // Layout direction (only if > 1 page)
                      if (_imagesPerPage > 1) ...[
                        _buildSectionTitle('Hướng phân trang trong trang'),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(
                              value: true,
                              label: Text('Theo chiều dọc'),
                              icon: Icon(Icons.unfold_more),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text('Theo chiều ngang'),
                              icon: Icon(Icons.unfold_less),
                            ),
                          ],
                          selected: {_isVerticalLayout},
                          onSelectionChanged: (value) {
                            setState(() => _isVerticalLayout = value.first);
                            setModalState(() {});
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                      // Zoom/Scale
                      _buildSectionTitle('Thu phóng (Scale): ${_imageScale.toStringAsFixed(1)}x'),
                      Slider(
                        value: _imageScale,
                        min: 0.5,
                        max: 1.5,
                        divisions: 10,
                        label: _imageScale.toStringAsFixed(1),
                        onChanged: _autoScale ? null : (value) {
                          setState(() => _imageScale = value);
                          setModalState(() {});
                        },
                      ),
                      if (_autoScale)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Tắt "Tự động thu phóng" để điều chỉnh thủ công',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In & Lưu PDF'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showSettings,
            icon: const Icon(Icons.settings_suggest),
            tooltip: 'Cấu hình in',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async {
          if (widget.isCccd) {
            return await PdfService.generateCCCDPdfBytes(
              format,
              widget.imagePaths,
              isVertical: !_isLandscape,
            );
          } else {
            return await PdfService.generateDocumentPdfBytes(
              format,
              widget.imagePaths,
              isLandscape: _isLandscape,
              imagesPerPage: _imagesPerPage,
              imageScale: _imageScale,
              isVerticalLayout: _isVerticalLayout,
              autoRotate: _autoRotate,
            );
          }
        },
        useActions: true,
        canChangeOrientation: false, // We handle this ourselves
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showSettings,
                  icon: const Icon(Icons.tune),
                  label: const Text('CẤU HÌNH'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () async {
                    final format = PdfPageFormat.a4;
                    final bytes = widget.isCccd
                        ? await PdfService.generateCCCDPdfBytes(
                            format,
                            widget.imagePaths,
                            isVertical: !_isLandscape,
                          )
                        : await PdfService.generateDocumentPdfBytes(
                            format,
                            widget.imagePaths,
                            isLandscape: _isLandscape,
                            imagesPerPage: _imagesPerPage,
                            imageScale: _imageScale,
                            isVerticalLayout: _isVerticalLayout,
                            autoRotate: _autoRotate,
                          );

                    final fileName =
                        'ScannerVision_${DateTime.now().millisecondsSinceEpoch}.pdf';
                    final savedPath =
                        await PdfService.saveAndCopyPdf(bytes, fileName);

                    await PdfService.openFile(savedPath);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Đã lưu vào bộ nhớ và copy đường dẫn: $savedPath'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('LƯU & MỞ PDF'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
