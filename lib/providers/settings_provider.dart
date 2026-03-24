import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _showPreview = true;
  String? _saveFolder;
  bool _saveToGallery = true;
  bool _saveImageToClipboard = true;
  bool _savePdfPathToClipboard = false;

  bool get showPreview => _showPreview;
  String? get saveFolder => _saveFolder;
  bool get saveToGallery => _saveToGallery;
  bool get saveImageToClipboard => _saveImageToClipboard;
  bool get savePdfPathToClipboard => _savePdfPathToClipboard;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _showPreview = await SettingsService.shouldShowPreview();
    _saveFolder = await SettingsService.getSaveFolder();
    _saveToGallery = await SettingsService.shouldSaveToGallery();
    _saveImageToClipboard = await SettingsService.shouldSaveImageToClipboard();
    _savePdfPathToClipboard = await SettingsService.shouldSavePdfPathToClipboard();
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

  Future<void> setSaveImageToClipboard(bool value) async {
    await SettingsService.setSaveImageToClipboard(value);
    _saveImageToClipboard = value;
    notifyListeners();
  }

  Future<void> setSavePdfPathToClipboard(bool value) async {
    await SettingsService.setSavePdfPathToClipboard(value);
    _savePdfPathToClipboard = value;
    notifyListeners();
  }
}
