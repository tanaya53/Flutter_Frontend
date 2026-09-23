import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/api_constants.dart';
import 'api_service.dart';

class OfflineService extends ChangeNotifier {
  static final OfflineService _instance = OfflineService._internal();
  factory OfflineService() => _instance;
  OfflineService._internal();

  final ApiService _api = ApiService();
  bool _isOnline = true;
  int _pendingSyncCount = 0;

  bool get isOnline => _isOnline;
  int get pendingSyncCount => _pendingSyncCount;

  Future<void> init() async {
    await _loadPendingQueueCount();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
    if (_isOnline && _pendingSyncCount > 0) {
      syncPendingAttendance();
    }
  }

  Future<void> _loadPendingQueueCount() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_attendance_queue') ?? [];
    _pendingSyncCount = queue.length;
    notifyListeners();
  }

  /// Store attendance locally when offline or as immediate feedback
  Future<void> queueOfflineAttendance({
    required String date,
    required List<Map<String, dynamic>> attendances,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_attendance_queue') ?? [];

    final item = jsonEncode({
      'date': date,
      'attendances': attendances,
      'queued_at': DateTime.now().toIso8601String(),
    });

    queue.add(item);
    await prefs.setStringList('offline_attendance_queue', queue);
    _pendingSyncCount = queue.length;
    notifyListeners();

    // If online, trigger sync immediately
    if (_isOnline) {
      await syncPendingAttendance();
    }
  }

  /// Synchronize all pending offline attendance records to the Django server
  Future<int> syncPendingAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList('offline_attendance_queue') ?? [];

    if (queue.isEmpty) return 0;

    int syncedCount = 0;
    final remainingQueue = <String>[];

    for (final itemStr in queue) {
      try {
        final item = jsonDecode(itemStr);
        await _api.post(ApiConstants.bulkAttendance, {
          'date': item['date'],
          'attendances': item['attendances'],
        });
        syncedCount++;
      } catch (e) {
        // Keep in queue to retry
        remainingQueue.add(itemStr);
      }
    }

    await prefs.setStringList('offline_attendance_queue', remainingQueue);
    _pendingSyncCount = remainingQueue.length;
    notifyListeners();

    return syncedCount;
  }
}
