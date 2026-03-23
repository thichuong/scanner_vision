import 'package:flutter/material.dart';
import '../models/scan_session.dart';
import '../services/storage_service.dart';

class SessionProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ScanSession> _sessions = [];
  bool _isLoading = false;

  List<ScanSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  SessionProvider() {
    loadSessions();
  }

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();
    _sessions = await _storageService.getSessions();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveSession(ScanSession session) async {
    await _storageService.saveSession(session);
    await loadSessions();
  }

  Future<void> deleteSession(String id) async {
    await _storageService.deleteSession(id);
    await loadSessions();
  }
}
