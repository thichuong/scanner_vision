import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showPreview = true;
  String? _saveFolder;

  bool get showPreview => _showPreview;
  String? get saveFolder => _saveFolder;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _showPreview = await SettingsService.shouldShowPreview();
    _saveFolder = await SettingsService.getSaveFolder();
    notifyListeners();
  }

  Future<void> setShowPreview(bool value) async {
    await SettingsService.setShowPreview(value);
    _showPreview = value;
    notifyListeners();
  }

  Future<void> setSaveFolder(String path) async {
    await SettingsService.setSaveFolder(path);
    _saveFolder = path;
    notifyListeners();
  }
}
