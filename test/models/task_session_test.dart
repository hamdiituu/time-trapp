import 'package:flutter_test/flutter_test.dart';
import 'package:time_trapp/models/task_session.dart';

void main() {
  group('TaskSession', () {
    test('should create TaskSession with required fields', () {
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      expect(session.id, 'test-id');
      expect(session.purpose, 'Test Purpose');
      expect(session.goal, 'Test Goal');
      expect(session.startTime, DateTime(2025, 1, 1, 12, 0, 0));
      expect(session.link, isNull);
      expect(session.endTime, isNull);
      expect(session.duration, isNull);
      expect(session.isActive, isTrue);
    });

    test('should create TaskSession with all fields', () {
      final startTime = DateTime(2025, 1, 1, 12, 0, 0);
      final endTime = DateTime(2025, 1, 1, 13, 30, 0);
      final duration = Duration(hours: 1, minutes: 30);

      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        link: 'https://example.com',
        startTime: startTime,
        endTime: endTime,
        duration: duration,
      );

      expect(session.id, 'test-id');
      expect(session.purpose, 'Test Purpose');
      expect(session.goal, 'Test Goal');
      expect(session.link, 'https://example.com');
      expect(session.startTime, startTime);
      expect(session.endTime, endTime);
      expect(session.duration, duration);
      expect(session.isActive, isFalse);
    });

    test('should create copy with updated fields', () {
      final originalSession = TaskSession(
        id: 'test-id',
        purpose: 'Original Purpose',
        goal: 'Original Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      final updatedSession = originalSession.copyWith(
        purpose: 'Updated Purpose',
        endTime: DateTime(2025, 1, 1, 13, 0, 0),
        duration: Duration(hours: 1),
      );

      expect(updatedSession.id, 'test-id');
      expect(updatedSession.purpose, 'Updated Purpose');
      expect(updatedSession.goal, 'Original Goal');
      expect(updatedSession.startTime, DateTime(2025, 1, 1, 12, 0, 0));
      expect(updatedSession.endTime, DateTime(2025, 1, 1, 13, 0, 0));
      expect(updatedSession.duration, Duration(hours: 1));
      expect(updatedSession.isActive, isFalse);
    });

    test('should format duration correctly', () {
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
        duration: Duration(hours: 2, minutes: 30, seconds: 45),
      );

      expect(session.formattedDuration, '02:30:45');
    });

    test('should format duration with zero hours', () {
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
        duration: Duration(minutes: 30, seconds: 15),
      );

      expect(session.formattedDuration, '00:30:15');
    });

    test('should return default duration for null duration', () {
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
      );

      expect(session.formattedDuration, '0:00:00');
    });

    test('should convert to JSON correctly', () {
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        link: 'https://example.com',
        startTime: DateTime(2025, 1, 1, 12, 0, 0),
        endTime: DateTime(2025, 1, 1, 13, 30, 0),
        duration: Duration(hours: 1, minutes: 30),
      );

      final json = session.toJson();

      expect(json['id'], 'test-id');
      expect(json['purpose'], 'Test Purpose');
      expect(json['goal'], 'Test Goal');
      expect(json['link'], 'https://example.com');
      expect(json['startTime'], '2025-01-01T12:00:00.000');
      expect(json['endTime'], '2025-01-01T13:30:00.000');
      expect(json['duration'], 5400000); // milliseconds
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'purpose': 'Test Purpose',
        'goal': 'Test Goal',
        'link': 'https://example.com',
        'startTime': '2025-01-01T12:00:00.000',
        'endTime': '2025-01-01T13:30:00.000',
        'duration': 5400000,
      };

      final session = TaskSession.fromJson(json);

      expect(session.id, 'test-id');
      expect(session.purpose, 'Test Purpose');
      expect(session.goal, 'Test Goal');
      expect(session.link, 'https://example.com');
      expect(session.startTime, DateTime(2025, 1, 1, 12, 0, 0));
      expect(session.endTime, DateTime(2025, 1, 1, 13, 30, 0));
      expect(session.duration, Duration(hours: 1, minutes: 30));
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 'test-id',
        'purpose': 'Test Purpose',
        'goal': 'Test Goal',
        'startTime': '2025-01-01T12:00:00.000',
      };

      final session = TaskSession.fromJson(json);

      expect(session.id, 'test-id');
      expect(session.purpose, 'Test Purpose');
      expect(session.goal, 'Test Goal');
      expect(session.link, isNull);
      expect(session.endTime, isNull);
      expect(session.duration, isNull);
    });
  });
}
