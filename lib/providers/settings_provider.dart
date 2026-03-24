import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showPreview = true;
  String? _saveFolder;
  bool _saveToGallery = true;

  bool get showPreview => _showPreview;
  String? get saveFolder => _saveFolder;
  bool get saveToGallery => _saveToGallery;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _showPreview = await SettingsService.shouldShowPreview();
    _saveFolder = await SettingsService.getSaveFolder();
    _saveToGallery = await SettingsService.shouldSaveToGallery();
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

  Future<void> setSaveToGallery(bool value) async {
    await SettingsService.setSaveToGallery(value);
    _saveToGallery = value;
    notifyListeners();
  }
}
