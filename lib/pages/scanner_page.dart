import 'package:flutter/material.dart';
import '../scanner_service.dart';
import '../models/scan_session.dart';
import '../models/cccd_model.dart';
import 'scan_review_page.dart';

class ScannerPage extends StatefulWidget {
  final String scanType;

  const ScannerPage({super.key, required this.scanType});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ScannerService _scannerService = ScannerService();
  ScanSession? _currentSession;
  bool _isInitialScanStarted = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    // Start scanning immediately upon entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialScanStarted) {
        _startScan();
        _isInitialScanStarted = true;
      }
    });
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _startScan({List<String>? initialImages}) async {
    setState(() => _isScanning = true);
    
    if (widget.scanType == 'document') {
      final result = await _scannerService.scanDocument();
      if (result != null && result.images != null && result.images!.isNotEmpty) {
        setState(() {
          _currentSession = ScanSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now(),
            imagePaths: result.images!,
            type: 'document',
          );
        });
      } else if (_currentSession == null && mounted) {
        Navigator.pop(context); // Cancel entire process if first scan failed
      }
    } else {
      final result = await _scannerService.scanCCCD(initialImages: initialImages);
      if (result != null && result.images.isNotEmpty) {
        setState(() {
          _currentSession = ScanSession(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now(),
            imagePaths: result.images,
            type: 'cccd',
            cccdData: result.qrData != null
                ? CCCDModel.fromQR(result.qrData!, images: result.images)
                : null,
          );
        });
      } else if (initialImages == null && _currentSession == null && mounted) {
        Navigator.pop(context); // Cancel entire process if first scan failed
      }
    }
    
    if (mounted) setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentSession == null || _isScanning) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                _isScanning ? 'Đang chuẩn bị máy ảnh...' : 'Vui lòng chờ...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ScanReviewPage(
      session: _currentSession!,
      isEmbedded: true,
      onScanMore: () => _startScan(initialImages: _currentSession!.imagePaths),
      onDone: () => Navigator.pop(context, true),
      onCancel: () => Navigator.pop(context),
    );
  }
}
