import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/task_session.dart';
import '../services/storage_service.dart';
import '../services/webhook_service.dart';
import '../models/app_settings.dart';
import '../models/webhook_config.dart';

// Abstract interfaces for dependency injection
abstract class IStorageService {
  Future<void> saveCurrentSession(TaskSession? session);
  Future<void> addSession(TaskSession session);
  Future<void> updateSession(TaskSession session);
  Future<void> saveSettings(AppSettings settings);
  Future<List<TaskSession>> loadSessions();
  Future<TaskSession?> loadCurrentSession();
  Future<AppSettings> loadSettings();
}

abstract class IWebhookService {
  Future<void> sendSessionStartWebhook(TaskSession session, WebhookConfig config, {String? userName});
  Future<void> sendSessionStopWebhook(TaskSession session, WebhookConfig config, {String? userName});
}

// Concrete implementations
class StorageServiceImpl implements IStorageService {
  @override
  Future<void> saveCurrentSession(TaskSession? session) => StorageService.saveCurrentSession(session);
  
  @override
  Future<void> addSession(TaskSession session) => StorageService.addSession(session);
  
  @override
  Future<void> updateSession(TaskSession session) => StorageService.updateSession(session);
  
  @override
  Future<void> saveSettings(AppSettings settings) => StorageService.saveSettings(settings);
  
  @override
  Future<List<TaskSession>> loadSessions() => StorageService.loadSessions();
  
  @override
  Future<TaskSession?> loadCurrentSession() => StorageService.loadCurrentSession();
  
  @override
  Future<AppSettings> loadSettings() => StorageService.loadSettings();
}

class WebhookServiceImpl implements IWebhookService {
  @override
  Future<void> sendSessionStartWebhook(TaskSession session, WebhookConfig config, {String? userName}) =>
      WebhookService.sendSessionStartWebhook(session, config, userName: userName);
  
  @override
  Future<void> sendSessionStopWebhook(TaskSession session, WebhookConfig config, {String? userName}) =>
      WebhookService.sendSessionStopWebhook(session, config, userName: userName);
}

// Provider for managing timer state and sessions
class TimerProvider with ChangeNotifier {
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  TaskSession? _currentSession;
  bool _isRunning = false;
  AppSettings _settings = AppSettings();
  
  final IStorageService _storageService;
  final IWebhookService _webhookService;

  // Constructor with dependency injection
  TimerProvider({
    IStorageService? storageService,
    IWebhookService? webhookService,
  }) : _storageService = storageService ?? StorageServiceImpl(),
       _webhookService = webhookService ?? WebhookServiceImpl();

  // Getters
  Duration get elapsedTime => _elapsedTime;
  TaskSession? get currentSession => _currentSession;
  bool get isRunning => _isRunning;
  AppSettings get settings => _settings;

  // Initialize provider
  Future<void> initialize() async {
    _settings = await _storageService.loadSettings();
    _currentSession = await _storageService.loadCurrentSession();
    
    if (_currentSession != null && _currentSession!.isActive) {
      _isRunning = true;
      _elapsedTime = DateTime.now().difference(_currentSession!.startTime);
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
    await _storageService.saveCurrentSession(session);
    await _storageService.addSession(session);

    // Send webhook if configured
    if (_settings.webhookConfig.onStart) {
      await _webhookService.sendSessionStartWebhook(
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
    await _storageService.updateSession(updatedSession);
    await _storageService.saveCurrentSession(null);

    // Send webhook if configured
    if (_settings.webhookConfig.onStop) {
      await _webhookService.sendSessionStopWebhook(
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
        final newElapsedTime = DateTime.now().difference(_currentSession!.startTime);
        // Only notify listeners if elapsed time has actually changed
        if (newElapsedTime != _elapsedTime) {
          _elapsedTime = newElapsedTime;
          notifyListeners();
        }
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
    await _storageService.saveSettings(_settings);
    notifyListeners();
  }

  // Clear all data
  Future<void> clearAllData() async {
    // Stop current session if running
    if (_isRunning) {
      _timer?.cancel();
      _isRunning = false;
    }
    
    // Clear all data from storage
    await StorageService.clearAllData();
    
    // Reset state
    _currentSession = null;
    _elapsedTime = Duration.zero;
    _settings = AppSettings();
    
    notifyListeners();
  }

  // Get sessions for a specific date range
  Future<List<TaskSession>> getSessionsForDateRange(DateTime start, DateTime end) async {
    final allSessions = await _storageService.loadSessions();
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
