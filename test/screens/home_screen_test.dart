import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/screens/home_screen.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'home_screen_test.mocks.dart';

@GenerateMocks([TimerProvider])
void main() {
  group('HomeScreen', () {
    late MockTimerProvider mockTimerProvider;

    setUp(() {
      mockTimerProvider = MockTimerProvider();
      // Setup common mocks
      when(mockTimerProvider.getTodaysTotalTime()).thenAnswer((_) async => Duration.zero);
      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => []);
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const HomeScreen(),
        ),
      );
    }

    testWidgets('should display welcome message when user name is set', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(userName: 'Test User'),
      );
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Merhaba, Test User!'), findsOneWidget);
    });

    testWidgets('should not display welcome message when user name is empty', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(userName: ''),
      );
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Merhaba, Test User!'), findsNothing);
    });

    testWidgets('should display timer section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('01:23:45');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('01:23:45'), findsOneWidget);
    });

    testWidgets('should display start button when not running', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Başlat'), findsOneWidget);
    });

    testWidgets('should display stop button when running', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(true);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:05:30');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Durdur'), findsOneWidget);
    });

    testWidgets('should display current session info when running', (WidgetTester tester) async {
      // Arrange
      final session = TaskSession(
        id: 'test-id',
        purpose: 'Test Purpose',
        goal: 'Test Goal',
        startTime: DateTime.now(),
      );

      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(true);
      when(mockTimerProvider.currentSession).thenReturn(session);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:05:30');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test Purpose'), findsOneWidget);
      expect(find.text('Test Goal'), findsOneWidget);
    });

    testWidgets('should display no active session message when not running', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Henüz aktif bir seans yok'), findsOneWidget);
    });

    testWidgets('should display today summary section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');
      when(mockTimerProvider.getTodaysTotalTime()).thenAnswer((_) async => Duration(hours: 2, minutes: 30));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Wait for FutureBuilder

      // Assert
      expect(find.text('Bugünkü Özet'), findsOneWidget);
      expect(find.text('Toplam: 02:30'), findsOneWidget);
    });

    testWidgets('should display recent sessions section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Son Seanslar'), findsOneWidget);
    });

    testWidgets('should have navigation buttons in app bar', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should tap start button and show modal', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Başlat'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Yeni Seans Başlat'), findsOneWidget);
    });

    testWidgets('should tap stop button and show confirmation dialog', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(true);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:05:30');

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Durdur'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Seansı Durdur'), findsOneWidget);
      expect(find.text('Çalışma seansınızı durdurmak istediğinizden emin misiniz?'), findsOneWidget);
    });

    testWidgets('should tap reports button and navigate', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Raporlar'), findsOneWidget);
    });

    testWidgets('should tap settings button and navigate', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ayarlar'), findsOneWidget);
    });

    testWidgets('should tap menu button and show popup menu', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Timer Durumu'), findsOneWidget);
      expect(find.text('Seans Başlat/Durdur'), findsOneWidget);
      expect(find.text('Çıkış'), findsOneWidget);
    });
  });
}
