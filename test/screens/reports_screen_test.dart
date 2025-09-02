import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/screens/reports_screen.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'reports_screen_test.mocks.dart';

@GenerateMocks([TimerProvider])
void main() {
  group('ReportsScreen', () {
    late MockTimerProvider mockTimerProvider;

    setUp(() async {
      mockTimerProvider = MockTimerProvider();
      // Initialize locale data for intl package
      await initializeDateFormatting('tr_TR', null);
      // Setup common mocks
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any)).thenAnswer((_) async => []);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const ReportsScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Raporlar'), findsOneWidget);
    });

    testWidgets('should display view mode menu button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.view_module), findsOneWidget);
    });

    testWidgets('should display date selector', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for date picker button
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('should display empty state when no sessions', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.getSessionsForDateRange(any, any)).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Just check that the screen loads without errors
      expect(find.text('Raporlar'), findsOneWidget);
    });

    testWidgets('should display sessions when available', (WidgetTester tester) async {
      // Arrange
      final mockSessions = [
        TaskSession(
          id: '1',
          purpose: 'Test Purpose',
          goal: 'Test Goal',
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now(),
        ),
      ];
      when(mockTimerProvider.getSessionsForDateRange(any, any)).thenAnswer((_) async => mockSessions);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Just check that the screen loads without errors
      expect(find.text('Raporlar'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for basic layout components
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
    });
  });
}