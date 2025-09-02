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

    setUp(() {
      mockTimerProvider = MockTimerProvider();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const ReportsScreen(),
        ),
      );
    }

    testWidgets('should display reports title', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Raporlar'), findsOneWidget);
    });

    testWidgets('should display daily report section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Günlük Rapor'), findsOneWidget);
    });

    testWidgets('should display hourly report section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Saatlik Rapor'), findsOneWidget);
    });

    testWidgets('should display date picker for daily report', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Tarih Seç'), findsOneWidget);
    });

    testWidgets('should display date range picker for hourly report', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Başlangıç Tarihi'), findsOneWidget);
      expect(find.text('Bitiş Tarihi'), findsOneWidget);
    });

    testWidgets('should display generate report buttons', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Günlük Rapor Oluştur'), findsOneWidget);
      expect(find.text('Saatlik Rapor Oluştur'), findsOneWidget);
    });

    testWidgets('should display empty state when no sessions', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Günlük Rapor Oluştur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bu tarihte hiç seans bulunamadı'), findsOneWidget);
    });

    testWidgets('should display sessions when available', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Test Purpose 1',
          goal: 'Test Goal 1',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
        TaskSession(
          id: '2',
          purpose: 'Test Purpose 2',
          goal: 'Test Goal 2',
          startTime: DateTime(2025, 1, 1, 14, 0, 0),
          endTime: DateTime(2025, 1, 1, 16, 0, 0),
          duration: Duration(hours: 2),
        ),
      ];

      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Günlük Rapor Oluştur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Purpose 1'), findsOneWidget);
      expect(find.text('Test Purpose 2'), findsOneWidget);
      expect(find.text('01:30:00'), findsOneWidget);
      expect(find.text('02:00:00'), findsOneWidget);
    });

    testWidgets('should display total time for daily report', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Test Purpose 1',
          goal: 'Test Goal 1',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
        TaskSession(
          id: '2',
          purpose: 'Test Purpose 2',
          goal: 'Test Goal 2',
          startTime: DateTime(2025, 1, 1, 14, 0, 0),
          endTime: DateTime(2025, 1, 1, 16, 0, 0),
          duration: Duration(hours: 2),
        ),
      ];

      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Günlük Rapor Oluştur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Toplam Süre: 03:30:00'), findsOneWidget);
    });

    testWidgets('should display hourly breakdown for hourly report', (WidgetTester tester) async {
      // Arrange
      final sessions = [
        TaskSession(
          id: '1',
          purpose: 'Test Purpose 1',
          goal: 'Test Goal 1',
          startTime: DateTime(2025, 1, 1, 9, 0, 0),
          endTime: DateTime(2025, 1, 1, 10, 30, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
        TaskSession(
          id: '2',
          purpose: 'Test Purpose 2',
          goal: 'Test Goal 2',
          startTime: DateTime(2025, 1, 1, 9, 30, 0),
          endTime: DateTime(2025, 1, 1, 11, 0, 0),
          duration: Duration(hours: 1, minutes: 30),
        ),
      ];

      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Saatlik Rapor Oluştur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Saatlik Dağılım'), findsOneWidget);
    });

    testWidgets('should handle date selection for daily report', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Tarih Seç'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should handle date range selection for hourly report', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Başlangıç Tarihi'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display session details correctly', (WidgetTester tester) async {
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

      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.getSessionsForDateRange(any, any))
          .thenAnswer((_) async => sessions);

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Günlük Rapor Oluştur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Feature Implementation'), findsOneWidget);
      expect(find.text('https://github.com/project'), findsOneWidget);
      expect(find.text('09:00 - 10:30'), findsOneWidget);
      expect(find.text('01:30:00'), findsOneWidget);
    });
  });
}
