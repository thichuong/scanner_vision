import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showPreview = true;
  String? _saveFolder;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final showPreview = await SettingsService.shouldShowPreview();
    final folder = await SettingsService.getSaveFolder();
    setState(() {
      _showPreview = showPreview;
      _saveFolder = folder;
    });
  }

  Future<void> _pickFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      await SettingsService.setSaveFolder(selectedDirectory);
      setState(() {
        _saveFolder = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Hiện màn hình xem trước (Print Preview)'),
            subtitle: const Text(
              'Tắt để tự động lưu PDF luôn, không cần hỏi qua màn hình preview',
            ),
            value: _showPreview,
            onChanged: (val) async {
              await SettingsService.setShowPreview(val);
              setState(() {
                _showPreview = val;
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Thư mục mặc định lưu PDF'),
            subtitle: Text(_saveFolder ?? 'Mặc định (Downloads)'),
            trailing: const Icon(Icons.folder_open),
            onTap: _pickFolder,
          ),
        ],
      ),
    );
  }
}
