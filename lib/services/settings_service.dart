import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyShowPreview = 'show_print_preview';
  static const String _keySaveFolder = 'save_folder_path';
  static const String _keySaveToGallery = 'save_to_gallery';
  static const String _keySaveImageToClipboard = 'save_image_to_clipboard';
  static const String _keySavePdfPathToClipboard = 'save_pdf_path_to_clipboard';
  static const String _keyAutoScale = 'pdf_auto_scale';
  static const String _keyAutoRotate = 'pdf_auto_rotate';

  static Future<bool> shouldShowPreview() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowPreview) ?? true;
  }

  static Future<void> setShowPreview(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowPreview, value);
  }

  static Future<String?> getSaveFolder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySaveFolder);
  }

  static Future<void> setSaveFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySaveFolder, path);
  }

  static Future<bool> shouldSaveToGallery() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySaveToGallery) ?? true;
  }

  static Future<void> setSaveToGallery(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySaveToGallery, value);
  }

  static Future<bool> shouldSaveImageToClipboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySaveImageToClipboard) ?? true;
  }

  static Future<void> setSaveImageToClipboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySaveImageToClipboard, value);
  }

  static Future<bool> shouldSavePdfPathToClipboard() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySavePdfPathToClipboard) ?? false;
  }

  static Future<void> setSavePdfPathToClipboard(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySavePdfPathToClipboard, value);
  }

  static Future<bool> shouldAutoScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoScale) ?? true;
  }

  static Future<void> setAutoScale(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoScale, value);
  }

  static Future<bool> shouldAutoRotate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoRotate) ?? true;
  }

  static Future<void> setAutoRotate(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoRotate, value);
  }
}
