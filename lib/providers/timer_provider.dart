import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task_session.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../models/app_settings.dart';

// Provider for managing timer state and sessions
class TimerProvider with ChangeNotifier {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  TaskSession? _currentSession;
  bool _isRunning = false;
  AppSettings _settings = AppSettings();

  // Getters
  Duration get elapsedTime => _elapsedTime;
  TaskSession? get currentSession => _currentSession;
  bool get isRunning => _isRunning;
  AppSettings get settings => _settings;

  // Initialize provider
  Future<void> initialize() async {
    _settings = await StorageService.loadSettings();
    _currentSession = await StorageService.loadCurrentSession();
    
    if (_currentSession != null && _currentSession!.isActive) {
      _startTimer();
    }
    
    notifyListeners();
  }

  // Start a new session
  Future<void> startSession({
    required String purpose,
    required String goal,
    String? link,
  }) async {
    if (_isRunning) return;

    final session = TaskSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      purpose: purpose,
      goal: goal,
      link: link,
      startTime: DateTime.now(),
    );

    _currentSession = session;
    _elapsedTime = Duration.zero;
    _isRunning = true;

    // Save to storage
    await StorageService.saveCurrentSession(session);
    await StorageService.addSession(session);

    // Send webhook if configured
    if (_settings.webhookConfig.onStart) {
      await WebhookService.sendSessionStartWebhook(
        session, 
        _settings.webhookConfig,
        userName: _settings.userName,
      );
    }

    _startTimer();
    notifyListeners();
  }

  // Stop current session
  Future<void> stopSession() async {
    if (!_isRunning || _currentSession == null) return;

    _timer?.cancel();
    _isRunning = false;

    final endTime = DateTime.now();
    final duration = endTime.difference(_currentSession!.startTime);

    final updatedSession = _currentSession!.copyWith(
      endTime: endTime,
      duration: duration,
    );

    _currentSession = updatedSession;

    // Update in storage
    await StorageService.updateSession(updatedSession);
    await StorageService.saveCurrentSession(null);

    // Send webhook if configured
    if (_settings.webhookConfig.onStop) {
      await WebhookService.sendSessionStopWebhook(
        updatedSession, 
        _settings.webhookConfig,
        userName: _settings.userName,
      );
    }

    notifyListeners();
  }

  // Start the timer
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentSession != null) {
        _elapsedTime = DateTime.now().difference(_currentSession!.startTime);
        notifyListeners();
      }
    });
  }

  // Get formatted elapsed time
  String get formattedElapsedTime {
    final hours = _elapsedTime.inHours;
    final minutes = _elapsedTime.inMinutes.remainder(60);
    final seconds = _elapsedTime.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Update settings
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  // Get sessions for a specific date range
  Future<List<TaskSession>> getSessionsForDateRange(DateTime start, DateTime end) async {
    final allSessions = await StorageService.loadSessions();
    return allSessions.where((session) {
      return session.startTime.isAfter(start.subtract(const Duration(days: 1))) &&
             session.startTime.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get sessions for today
  Future<List<TaskSession>> getTodaysSessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getSessionsForDateRange(startOfDay, endOfDay);
  }

  // Get total time for today
  Future<Duration> getTodaysTotalTime() async {
    final todaysSessions = await getTodaysSessions();
    Duration total = Duration.zero;
    
    for (final session in todaysSessions) {
      if (session.duration != null) {
        total += session.duration!;
      }
    }
    
    return total;
  }

  // Cleanup
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
