import 'package:flutter/material.dart';
import 'scanner_service.dart';
import 'models/scan_session.dart';
import 'services/storage_service.dart';
import 'pages/session_detail_page.dart';
import 'pages/settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScannerService _scannerService = ScannerService();
  List<ScanSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final sessions = await StorageService().getSessions();
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scannerService.dispose();
    super.dispose();
  }

  Future<void> _scanDocument() async {
    final result = await _scannerService.scanDocument();
    if (result != null && result.images != null && result.images!.isNotEmpty) {
      final session = ScanSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        imagePaths: result.images!,
        type: 'document',
      );
      await StorageService().saveSession(session);
      _loadSessions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scanner Vision',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
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
      final session = ScanSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        imagePaths: result.capturedImages,
        type: 'cccd',
        cccdData: result,
      );
      await StorageService().saveSession(session);
      _loadSessions();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin CCCD hoặc mã QR!'),
          ),
        );
      }
    }
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có tài liệu nào.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Nhấn nút Scan bên dưới để bắt đầu.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final isCccd = session.type == 'cccd';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: isCccd
                  ? Colors.blue.withValues(alpha: 0.2)
                  : Colors.green.withValues(alpha: 0.2),
              child: Icon(
                isCccd ? Icons.credit_card : Icons.document_scanner,
                color: isCccd ? Colors.blue : Colors.green,
              ),
            ),
            title: Text(
              isCccd
                  ? 'CCCD - ${session.cccdData?.fullName ?? "Lỗi tên"}'
                  : 'Tài Liệu Scan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${session.imagePaths.length} ảnh - ${session.date.toString().substring(0, 16)}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionDetailPage(session: session),
                ),
              ).then((_) => _loadSessions());
            },
          ),
        );
      },
    );
  }
}
