import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/scan_session.dart';
import '../providers/session_provider.dart';
import 'session_detail_page.dart';
import 'settings_page.dart';
import 'scanner_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _scanDocument(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerPage(scanType: 'document'),
      ),
    );
    if (result == true) {
      if (context.mounted) {
        context.read<SessionProvider>().loadSessions();
      }
    }
  }

  Future<void> _scanCCCD(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerPage(scanType: 'cccd'),
      ),
    );
    if (result == true) {
      if (context.mounted) {
        context.read<SessionProvider>().loadSessions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionProvider>();
    final sessions = sessionProvider.sessions;
    final isLoading = sessionProvider.isLoading;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => sessionProvider.loadSessions(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 120, // More bottom padding for the buttons
              ),
              sliver: isLoading
                  ? const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : sessions.isEmpty
                      ? _buildEmptyState(context)
                      : _buildSessionList(context, sessions),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _scanDocument(context),
              icon: const Icon(Icons.document_scanner),
              label: const Text('Tài liệu'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().slideX(begin: -0.2, duration: 400.ms).fadeIn(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _scanCCCD(context),
              icon: const Icon(Icons.credit_card),
              label: const Text('CCCD'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().slideX(begin: 0.2, duration: 400.ms).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverAppBar.large(
      expandedHeight: 180,
      title: const Text('Scanner Vision'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
                colorScheme.primaryContainer,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -30,
                child: Icon(
                  Icons.document_scanner,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                left: 24,
                bottom: 80,
                child: Text(
                  'Your intelligent\nscanning solution',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ).animate().scale(duration: 600.ms).fade(),
            const SizedBox(height: 24),
            Text(
              'Chưa có tài liệu nào',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhấn nút "+" bên dưới để bắt đầu quét!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, List<ScanSession> sessions) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final session = sessions[index];
        final isCccd = session.type == 'cccd';

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Hero(
              tag: 'session_${session.id}',
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isCccd
                      ? Colors.blue.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                ),
                child: session.imagePaths.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(session.imagePaths.first),
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => Icon(
                            isCccd ? Icons.credit_card : Icons.description,
                            color: isCccd ? Colors.blue : Colors.green,
                          ),
                        ),
                      )
                    : Icon(
                        isCccd ? Icons.credit_card : Icons.description,
                        color: isCccd ? Colors.blue : Colors.green,
                      ),
              ),
            ),
            title: Text(
              isCccd
                  ? 'CCCD - ${session.cccdData?.fullName ?? "Lỗi tên"}'
                  : 'Tài Liệu Scan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${session.imagePaths.length} ảnh • ${session.date.toString().substring(0, 16)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SessionDetailPage(session: session),
                ),
              ).then((_) {
                if (context.mounted) {
                  context.read<SessionProvider>().loadSessions();
                }
              });
            },
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideY(
              begin: 0.2,
              duration: 400.ms,
            );
      }, childCount: sessions.length),
    );
  }

}
