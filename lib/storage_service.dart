import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<String> saveFile(String originalPath, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final newPath = '${directory.path}/$fileName';
    
    final originalFile = File(originalPath);
    if (await originalFile.exists()) {
      await originalFile.copy(newPath);
      return newPath;
    }
    throw Exception('File not found: $originalPath');
  }

  Future<List<String>> saveImages(List<String> imagePaths) async {
    final directory = await getApplicationDocumentsDirectory();
    final savedPaths = <String>[];
    
    for (int i = 0; i < imagePaths.length; i++) {
      final originalPath = imagePaths[i];
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}_$i.jpeg';
      final newPath = '${directory.path}/$fileName';
      
      final originalFile = File(originalPath);
      if (await originalFile.exists()) {
        await originalFile.copy(newPath);
        savedPaths.add(newPath);
      }
    }
    return savedPaths;
  }
}
