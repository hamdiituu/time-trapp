import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_session.dart';
import '../models/app_settings.dart';

// Service for handling local storage operations
class StorageService {
  static const String _sessionsKey = 'task_sessions';
  static const String _settingsKey = 'app_settings';
  static const String _currentSessionKey = 'current_session';

  // Get SharedPreferences instance
  static Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Save task sessions
  static Future<void> saveSessions(List<TaskSession> sessions) async {
    final prefs = await _prefs;
    final sessionsJson = sessions.map((session) => session.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
  }

  // Load task sessions
  static Future<List<TaskSession>> loadSessions() async {
    final prefs = await _prefs;
    final sessionsString = prefs.getString(_sessionsKey);
    
    if (sessionsString == null) return [];
    
    try {
      final sessionsJson = jsonDecode(sessionsString) as List;
      return sessionsJson.map((json) => TaskSession.fromJson(json)).toList();
    } catch (e) {
      print('Error loading sessions: $e');
      return [];
    }
  }

  // Add a new session
  static Future<void> addSession(TaskSession session) async {
    final sessions = await loadSessions();
    sessions.add(session);
    await saveSessions(sessions);
  }

  // Update an existing session
  static Future<void> updateSession(TaskSession session) async {
    final sessions = await loadSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    
    if (index != -1) {
      sessions[index] = session;
      await saveSessions(sessions);
    }
  }

  // Delete a session
  static Future<void> deleteSession(String sessionId) async {
    final sessions = await loadSessions();
    sessions.removeWhere((session) => session.id == sessionId);
    await saveSessions(sessions);
  }

  // Save current active session
  static Future<void> saveCurrentSession(TaskSession? session) async {
    final prefs = await _prefs;
    if (session != null) {
      await prefs.setString(_currentSessionKey, jsonEncode(session.toJson()));
    } else {
      await prefs.remove(_currentSessionKey);
    }
  }

  // Load current active session
  static Future<TaskSession?> loadCurrentSession() async {
    final prefs = await _prefs;
    final sessionString = prefs.getString(_currentSessionKey);
    
    if (sessionString == null) return null;
    
    try {
      final sessionJson = jsonDecode(sessionString);
      return TaskSession.fromJson(sessionJson);
    } catch (e) {
      print('Error loading current session: $e');
      return null;
    }
  }

  // Save app settings
  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _prefs;
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // Load app settings
  static Future<AppSettings> loadSettings() async {
    final prefs = await _prefs;
    final settingsString = prefs.getString(_settingsKey);
    
    if (settingsString == null) {
      return AppSettings();
    }
    
    try {
      final settingsJson = jsonDecode(settingsString);
      return AppSettings.fromJson(settingsJson);
    } catch (e) {
      print('Error loading settings: $e');
      return AppSettings();
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
