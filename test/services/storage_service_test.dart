import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_trapp/services/storage_service.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/webhook_config.dart';

void main() {
  group('StorageService', () {
    setUp(() {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load settings', () async {
      // Arrange
      final settings = AppSettings(
        userName: 'Test User',
        webhookConfig: WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onStart: true,
        ),
      );

      // Act
      await StorageService.saveSettings(settings);
      final loadedSettings = await StorageService.loadSettings();

      // Assert
      expect(loadedSettings.userName, 'Test User');
      expect(loadedSettings.webhookConfig.url, 'https://example.com/webhook');
      expect(loadedSettings.webhookConfig.method, 'POST');
      expect(loadedSettings.webhookConfig.onStart, isTrue);
    });

    test('should return default settings when none saved', () async {
      // Act
      final settings = await StorageService.loadSettings();

      // Assert
      expect(settings.userName, '');
      expect(settings.webhookConfig.url, '');
      expect(settings.webhookConfig.method, 'POST');
    });

    test('should save and load current session', () async {
      // Arrange
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      // Act
      await StorageService.saveCurrentSession(session);
      final loadedSession = await StorageService.loadCurrentSession();

      // Assert
      expect(loadedSession, isNotNull);
      expect(loadedSession!.id, 'test-id');
      expect(loadedSession.purpose, 'Test Purpose');
      expect(loadedSession.goal, 'Test Goal');
    });

    test('should return null when no current session saved', () async {
      // Act
      final session = await StorageService.loadCurrentSession();

      // Assert
      expect(session, isNull);
    });

    test('should clear current session', () async {
      // Arrange
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      await StorageService.saveCurrentSession(session);

      // Act
      await StorageService.saveCurrentSession(null);
      final loadedSession = await StorageService.loadCurrentSession();

      // Assert
      expect(loadedSession, isNull);
    });

    test('should save and load sessions', () async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Purpose 1',
          goal: 'Goal 1',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        ),
        TaskSession(
          id: '2',
          purpose: 'Purpose 2',
          goal: 'Goal 2',
          startTime: DateTime(2025, 1, 2, 12, 0, 0),
        ),
      ];

      // Act
      await StorageService.saveSessions(sessions);
      final loadedSessions = await StorageService.loadSessions();

      // Assert
      expect(loadedSessions.length, 2);
      expect(loadedSessions[0].id, '1');
      expect(loadedSessions[1].id, '2');
    });

    test('should return empty list when no sessions saved', () async {
      // Act
      final sessions = await StorageService.loadSessions();

      // Assert
      expect(sessions, isEmpty);
    });

    test('should add session to existing sessions', () async {
      // Arrange
      final existingSessions = [
        TaskSession(
          id: '1',
          purpose: 'Purpose 1',
          goal: 'Goal 1',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        ),
      ];

      await StorageService.saveSessions(existingSessions);

      final newSession = TaskSession(
        id: '2',
        purpose: 'Purpose 2',
        goal: 'Goal 2',
        startTime: DateTime(2025, 1, 2, 12, 0, 0),
      );

      // Act
      await StorageService.addSession(newSession);
      final loadedSessions = await StorageService.loadSessions();

      // Assert
      expect(loadedSessions.length, 2);
      expect(loadedSessions[0].id, '1');
      expect(loadedSessions[1].id, '2');
    });

    test('should update existing session', () async {
      // Arrange
      final originalSession = TaskSession(
        id: '1',
        purpose: 'Original Purpose',
        goal: 'Original Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      await StorageService.addSession(originalSession);

      final updatedSession = originalSession.copyWith(
        purpose: 'Updated Purpose',
        endTime: DateTime(2025, 1, 1, 13, 0, 0),
        duration: Duration(hours: 1),
      );

      // Act
      await StorageService.updateSession(updatedSession);
      final loadedSessions = await StorageService.loadSessions();

      // Assert
      expect(loadedSessions.length, 1);
      expect(loadedSessions[0].purpose, 'Updated Purpose');
      expect(loadedSessions[0].endTime, isNotNull);
      expect(loadedSessions[0].duration, Duration(hours: 1));
    });

    test('should handle malformed JSON gracefully', () async {
      // Arrange - Set invalid JSON in shared preferences
      SharedPreferences.setMockInitialValues({
        'task_sessions': 'invalid json',
        'current_session': 'invalid json',
        'app_settings': 'invalid json',
      });

      // Act & Assert - Should not throw exceptions
      expect(() async => await StorageService.loadSessions(), returnsNormally);
      expect(() async => await StorageService.loadCurrentSession(), returnsNormally);
      expect(() async => await StorageService.loadSettings(), returnsNormally);
    });

    test('should handle null values in shared preferences', () async {
      // Arrange - Set empty values (null is not allowed in SharedPreferences)
      SharedPreferences.setMockInitialValues({});

      // Act
      final sessions = await StorageService.loadSessions();
      final currentSession = await StorageService.loadCurrentSession();
      final settings = await StorageService.loadSettings();

      // Assert
      expect(sessions, isEmpty);
      expect(currentSession, isNull);
      expect(settings, isA<AppSettings>());
    });
  });
}