import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _pickFolder(BuildContext context) async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      if (context.mounted) {
        context.read<SettingsProvider>().setSaveFolder(selectedDirectory);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final showPreview = settingsProvider.showPreview;
    final saveFolder = settingsProvider.saveFolder;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.medium(
            title: Text('Cài đặt'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SwitchListTile(
                title: const Text('Hiện màn hình xem trước'),
                subtitle: const Text(
                  'Tắt để tự động lưu PDF luôn, không cần hỏi qua màn hình preview',
                ),
                value: showPreview,
                onChanged: (val) {
                  settingsProvider.setShowPreview(val);
                },
              ),
              const Divider(indent: 16, endIndent: 16),
              ListTile(
                title: const Text('Thư mục mặc định lưu PDF'),
                subtitle: Text(saveFolder ?? 'Mặc định (Downloads)'),
                trailing: const Icon(Icons.folder_open),
                onTap: () => _pickFolder(context),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
