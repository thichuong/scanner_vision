import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyShowPreview = 'show_print_preview';
  static const String _keySaveFolder = 'save_folder_path';

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
}
