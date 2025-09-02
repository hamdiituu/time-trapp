import 'package:flutter_test/flutter_test.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/webhook_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'timer_provider_test.mocks.dart';

@GenerateMocks([IStorageService, IWebhookService])
void main() {
  group('TimerProvider', () {
    late TimerProvider timerProvider;
    late MockIStorageService mockStorageService;
    late MockIWebhookService mockWebhookService;

    setUp(() {
      mockStorageService = MockIStorageService();
      mockWebhookService = MockIWebhookService();
      timerProvider = TimerProvider(
        storageService: mockStorageService,
        webhookService: mockWebhookService,
      );
    });

    tearDown(() {
      timerProvider.dispose();
    });

    test('should initialize with default values', () {
      expect(timerProvider.elapsedTime, Duration.zero);
      expect(timerProvider.currentSession, isNull);
      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.settings, isA<AppSettings>());
    });

    test('should start session correctly', () async {
      // Arrange
      when(mockStorageService.saveCurrentSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.addSession(any))
          .thenAnswer((_) async => {});

      // Act
      await timerProvider.startSession(
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        link: 'https://example.com',
      );

      // Assert
      expect(timerProvider.isRunning, isTrue);
      expect(timerProvider.currentSession, isNotNull);
      expect(timerProvider.currentSession!.purpose, 'Test Purpose');
      expect(timerProvider.currentSession!.goal, 'Test Goal');
      expect(timerProvider.currentSession!.link, 'https://example.com');
      expect(timerProvider.currentSession!.isActive, isTrue);
    });

    test('should start session without link', () async {
      // Arrange
      when(mockStorageService.saveCurrentSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.addSession(any))
          .thenAnswer((_) async => {});

      // Act
      await timerProvider.startSession(
        purpose: 'Test Purpose',
        goal: 'Test Goal',
      );

      // Assert
      expect(timerProvider.isRunning, isTrue);
      expect(timerProvider.currentSession, isNotNull);
      expect(timerProvider.currentSession!.purpose, 'Test Purpose');
      expect(timerProvider.currentSession!.goal, 'Test Goal');
      expect(timerProvider.currentSession!.link, isNull);
    });

    test('should not start session if already running', () async {
      // Arrange
      when(mockStorageService.saveCurrentSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.addSession(any))
          .thenAnswer((_) async => {});

      // Start first session
      await timerProvider.startSession(
        purpose: 'First Purpose',
        goal: 'First Goal',
      );

      final firstSession = timerProvider.currentSession;

      // Act - Try to start second session
      await timerProvider.startSession(
        purpose: 'Second Purpose',
        goal: 'Second Goal',
      );

      // Assert - Should still be first session
      expect(timerProvider.currentSession, firstSession);
      expect(timerProvider.currentSession!.purpose, 'First Purpose');
    });

    test('should stop session correctly', () async {
      // Arrange
      when(mockStorageService.saveCurrentSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.addSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.updateSession(any))
          .thenAnswer((_) async => {});

      // Start session
      await timerProvider.startSession(
        purpose: 'Test Purpose',
        goal: 'Test Goal',
      );

      // Act
      await timerProvider.stopSession();

      // Assert
      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.currentSession, isNotNull);
      expect(timerProvider.currentSession!.isActive, isFalse);
      expect(timerProvider.currentSession!.endTime, isNotNull);
      expect(timerProvider.currentSession!.duration, isNotNull);
    });

    test('should not stop session if not running', () async {
      // Act
      await timerProvider.stopSession();

      // Assert
      expect(timerProvider.isRunning, isFalse);
      expect(timerProvider.currentSession, isNull);
    });

    test('should format elapsed time correctly', () async {
      // Arrange
      when(mockStorageService.saveCurrentSession(any))
          .thenAnswer((_) async => {});
      when(mockStorageService.addSession(any))
          .thenAnswer((_) async => {});

      // Start session
      await timerProvider.startSession(
        purpose: 'Test Purpose',
        goal: 'Test Goal',
      );

      // Wait a bit to get some elapsed time
      await Future.delayed(Duration(milliseconds: 100));

      // Act
      final formattedTime = timerProvider.formattedElapsedTime;

      // Assert
      expect(formattedTime, isA<String>());
      expect(formattedTime, matches(RegExp(r'^\d{2}:\d{2}:\d{2}$')));
    });

    test('should update settings correctly', () async {
      // Arrange
      final newSettings = AppSettings(userName: 'New User');
      when(mockStorageService.saveSettings(any))
          .thenAnswer((_) async => {});

      // Act
      await timerProvider.updateSettings(newSettings);

      // Assert
      expect(timerProvider.settings.userName, 'New User');
    });

    test('should get sessions for date range', () async {
      // Arrange
      final startDate = DateTime(2025, 1, 1);
      final endDate = DateTime(2025, 1, 31);
      final mockSessions = [
        TaskSession(
          id: '1',
          purpose: 'Test 1',
          goal: 'Goal 1',
          startTime: DateTime(2025, 1, 15),
        ),
        TaskSession(
          id: '2',
          purpose: 'Test 2',
          goal: 'Goal 2',
          startTime: DateTime(2025, 2, 1), // Outside range
        ),
      ];

      when(mockStorageService.loadSessions())
          .thenAnswer((_) async => mockSessions);

      // Act
      final sessions = await timerProvider.getSessionsForDateRange(startDate, endDate);

      // Assert
      expect(sessions.length, 1);
      expect(sessions.first.id, '1');
    });

    test('should get today sessions', () async {
      // Arrange
      final today = DateTime.now();
      final mockSessions = [
        TaskSession(
          id: '1',
          purpose: 'Today Session',
          goal: 'Today Goal',
          startTime: today,
        ),
        TaskSession(
          id: '2',
          purpose: 'Yesterday Session',
          goal: 'Yesterday Goal',
          startTime: today.subtract(Duration(days: 2)), // Changed to 2 days ago
        ),
      ];

      when(mockStorageService.loadSessions())
          .thenAnswer((_) async => mockSessions);

      // Act
      final sessions = await timerProvider.getTodaysSessions();

      // Assert
      expect(sessions.length, 1);
      expect(sessions.first.id, '1');
    });

    test('should calculate today total time', () async {
      // Arrange
      final today = DateTime.now();
      final mockSessions = [
        TaskSession(
          id: '1',
          purpose: 'Session 1',
          goal: 'Goal 1',
          startTime: today,
          duration: Duration(hours: 2, minutes: 30),
        ),
        TaskSession(
          id: '2',
          purpose: 'Session 2',
          goal: 'Goal 2',
          startTime: today,
          duration: Duration(hours: 1, minutes: 15),
        ),
      ];

      when(mockStorageService.loadSessions())
          .thenAnswer((_) async => mockSessions);

      // Act
      final totalTime = await timerProvider.getTodaysTotalTime();

      // Assert
      expect(totalTime, Duration(hours: 3, minutes: 45));
    });

    test('should handle empty sessions list', () async {
      // Arrange
      when(mockStorageService.loadSessions())
          .thenAnswer((_) async => []);

      // Act
      final totalTime = await timerProvider.getTodaysTotalTime();

      // Assert
      expect(totalTime, Duration.zero);
    });

    test('should dispose correctly', () {
      // Create a separate provider for this test to avoid tearDown conflict
      final testProvider = TimerProvider(
        storageService: mockStorageService,
        webhookService: mockWebhookService,
      );
      
      // Act & Assert - Should not throw any errors
      expect(() => testProvider.dispose(), returnsNormally);
    });
  });
}
