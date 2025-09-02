import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:time_trapp/services/webhook_service.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:time_trapp/models/webhook_config.dart';

import 'webhook_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('WebhookService', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // Set the global client for WebhookService
      WebhookService.setClient(mockClient);
    });

    group('sendSessionStartWebhook', () {
      test('should send webhook when configured and enabled', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onStart: true,
          sendDataInBody: true,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStartWebhook(
          session,
          config,
          userName: 'Test User',
        );

        // Assert
        verify(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });

      test('should not send webhook when not configured', () async {
        // Arrange
        final config = WebhookConfig(
          url: '',
          onStart: true,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verifyNever(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')));
      });

      test('should not send webhook when disabled', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          onStart: false,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verifyNever(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')));
      });

      test('should send data as query parameters when configured', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'GET',
          onStart: true,
          sendDataInBody: false,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        when(mockClient.get(any)).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verify(mockClient.get(any)).called(1);
      });
    });

    group('sendSessionStopWebhook', () {
      test('should send webhook with session data', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onStop: true,
          sendDataInBody: true,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
          endTime: DateTime(2025, 1, 1, 13, 0, 0),
          duration: Duration(hours: 1),
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStopWebhook(
          session,
          config,
          userName: 'Test User',
        );

        // Assert
        verify(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('sendAppOpenWebhook', () {
      test('should send webhook when configured', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onAppOpen: true,
          sendDataInBody: true,
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendAppOpenWebhook(
          config,
          userName: 'Test User',
        );

        // Assert
        verify(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('sendAppCloseWebhook', () {
      test('should send webhook when configured', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onAppClose: true,
          sendDataInBody: true,
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendAppCloseWebhook(
          config,
          userName: 'Test User',
        );

        // Assert
        verify(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('testWebhook', () {
      test('should return true for successful test', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          sendDataInBody: true,
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        final result = await WebhookService.testWebhook(config);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for failed test', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          sendDataInBody: true,
        );

        when(mockClient.post(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Error', 500));

        // Act
        final result = await WebhookService.testWebhook(config);

        // Assert
        expect(result, isFalse);
      });
    });

    group('HTTP methods', () {
      test('should support GET method', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'GET',
          onStart: true,
          sendDataInBody: false,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        when(mockClient.get(any)).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verify(mockClient.get(any)).called(1);
      });

      test('should support PUT method', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'PUT',
          onStart: true,
          sendDataInBody: true,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        when(mockClient.put(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verify(mockClient.put(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });

      test('should support PATCH method', () async {
        // Arrange
        final config = WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'PATCH',
          onStart: true,
          sendDataInBody: true,
        );

        final session = TaskSession(
          id: 'test-id',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime(2025, 1, 1, 12, 0, 0),
        );

        when(mockClient.patch(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('OK', 200));

        // Act
        await WebhookService.sendSessionStartWebhook(session, config);

        // Assert
        verify(mockClient.patch(
          Uri.parse('https://example.com/webhook'),
          headers: {'Content-Type': 'application/json'},
          body: anyNamed('body'),
        )).called(1);
      });
    });
  });
}
