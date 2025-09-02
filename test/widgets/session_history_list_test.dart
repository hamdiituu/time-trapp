import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/widgets/session_history_list.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'session_history_list_test.mocks.dart';

@GenerateMocks([TimerProvider])
void main() {
  group('SessionHistoryList', () {
    late MockTimerProvider mockTimerProvider;

    setUp(() {
      mockTimerProvider = MockTimerProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<TimerProvider>.value(
            value: mockTimerProvider,
            child: const SessionHistoryList(),
          ),
        ),
      );
    }

    testWidgets('should display empty state when no sessions', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Henüz bugün için seans yok'), findsOneWidget);
      expect(find.text('İlk çalışma seansınızı başlatın!'), findsOneWidget);
    });

    testWidgets('should display sessions when available', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
        TaskSession(
          id: '2',
          purpose: 'Testing',
          goal: 'Bug Fixes',
          startTime: DateTime(2025, 1, 1, 14, 0, 0),
          endTime: DateTime(2025, 1, 1, 16, 0, 0),
          duration: Duration(hours: 2),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Feature Implementation'), findsOneWidget);
      expect(find.text('Testing'), findsOneWidget);
      expect(find.text('Bug Fixes'), findsOneWidget);
    });

    testWidgets('should display session duration correctly', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('01:30:00'), findsOneWidget);
    });

    testWidgets('should display session time range correctly', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('09:00 - 10:30'), findsOneWidget);
    });

    testWidgets('should display link when available', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          link: 'https://github.com/project',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('https://github.com/project'), findsOneWidget);
    });

    testWidgets('should not display link when not available', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('https://github.com/project'), findsNothing);
    });

    testWidgets('should display active session indicator', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime.now(),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Aktif'), findsOneWidget);
    });

    testWidgets('should not display active indicator for completed sessions', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Aktif'), findsNothing);
    });

    testWidgets('should display multiple sessions in order', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'First Session',
          goal: 'First Goal',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 0, 0),
          duration: Duration(hours: 1),
        ),
        TaskSession(
          id: '2',
          purpose: 'Second Session',
          goal: 'Second Goal',
          startTime: DateTime(2025, 1, 1, 14, 0, 0),
          endTime: DateTime(2025, 1, 1, 16, 0, 0),
          duration: Duration(hours: 2),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('First Session'), findsOneWidget);
      expect(find.text('Second Session'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle long text gracefully', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Very Long Purpose Text That Should Be Handled Gracefully',
          goal: 'Very Long Goal Text That Should Also Be Handled Gracefully',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Very Long Purpose Text That Should Be Handled Gracefully'), findsOneWidget);
      expect(find.text('Very Long Goal Text That Should Also Be Handled Gracefully'), findsOneWidget);
    });

    testWidgets('should display proper icons', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Development',
          goal: 'Feature Implementation',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => sessions);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.access_time_outlined), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });
  });
}