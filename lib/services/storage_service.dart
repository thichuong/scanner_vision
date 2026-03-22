import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/scan_session.dart';
import '../models/cccd_model.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  static const String _fileName = 'scan_sessions.json';

  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<List<ScanSession>> getSessions() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => ScanSession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error reading sessions: $e');
      return [];
    }
  }

  Future<void> saveSession(ScanSession session) async {
    try {
      // 1. Copy images from temp to permanent directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final List<String> newImagePaths = [];
      for (final tempPath in session.imagePaths) {
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          final fileName = tempPath.split('/').last;
          final newPath = '${imagesDir.path}/${session.id}_$fileName';
          await tempFile.copy(newPath);
          newImagePaths.add(newPath);
        } else {
          // If the image was already persistently saved, just reuse the path
          newImagePaths.add(tempPath);
        }
      }

      // 1b. Update CCCD data with new persistent paths
      CCCDModel? newCccdData = session.cccdData;
      if (newCccdData != null) {
        newCccdData = CCCDModel(
          id: newCccdData.id,
          oldId: newCccdData.oldId,
          fullName: newCccdData.fullName,
          dob: newCccdData.dob,
          gender: newCccdData.gender,
          address: newCccdData.address,
          issueDate: newCccdData.issueDate,
          capturedImages: newImagePaths,
        );
      }

      // Update session with new permanent image paths
      final sessionToSave = ScanSession(
        id: session.id,
        date: session.date,
        type: session.type,
        cccdData: newCccdData,
        imagePaths: newImagePaths,
      );

      // 2. Read existing sessions
      final sessions = await getSessions();

      // 3. Add new session and save
      sessions.insert(0, sessionToSave); // Add to beginning

      final file = await _getFile();
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving session: $e');
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final sessions = await getSessions();

      // Delete images
      try {
        final sessionToDelete = sessions.firstWhere((s) => s.id == id);
        for (final path in sessionToDelete.imagePaths) {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
          }
        }
      } catch (e) {
        // Session not found or error deleting files, ignore and continue removing from json
      }

      // Remove from list and save
      sessions.removeWhere((s) => s.id == id);
      final file = await _getFile();
      final jsonList = sessions.map((s) => s.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
  }
}
