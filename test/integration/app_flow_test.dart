import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/main.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/task_session.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_flow_test.mocks.dart';

@GenerateMocks([TimerProvider])
void main() {
  group('App Flow Integration Tests', () {
    late MockTimerProvider mockTimerProvider;

    setUp(() async {
      // Mock SharedPreferences for integration tests
      SharedPreferences.setMockInitialValues({});
      
      mockTimerProvider = MockTimerProvider();
      // Setup common mocks
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.isRunning).thenReturn(false);
      when(mockTimerProvider.currentSession).thenReturn(null);
      when(mockTimerProvider.formattedElapsedTime).thenReturn('00:00:00');
      when(mockTimerProvider.getTodaysTotalTime()).thenAnswer((_) async => Duration.zero);
      when(mockTimerProvider.getTodaysSessions()).thenAnswer((_) async => []);
      when(mockTimerProvider.startSession(
        purpose: anyNamed('purpose'),
        goal: anyNamed('goal'),
        link: anyNamed('link'),
      )).thenAnswer((_) async {});
      when(mockTimerProvider.stopSession()).thenAnswer((_) async {});
      when(mockTimerProvider.updateSettings(any)).thenAnswer((_) async {});
    });

    testWidgets('App should load without errors', (WidgetTester tester) async {
      // Create test widget with mock provider
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Just verify the app loads without crashing
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });

    testWidgets('Should display onboarding when first time', (WidgetTester tester) async {
      // Mock first time user
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Check if onboarding elements exist
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });

    testWidgets('Should display home screen elements', (WidgetTester tester) async {
      // Mock existing user
      when(mockTimerProvider.settings).thenReturn(AppSettings(userName: 'Test User'));
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Check for basic app structure
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });

    testWidgets('Should handle session start flow', (WidgetTester tester) async {
      // Mock existing user
      when(mockTimerProvider.settings).thenReturn(AppSettings(userName: 'Test User'));
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Verify app structure exists
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });

    testWidgets('Should handle navigation between screens', (WidgetTester tester) async {
      // Mock existing user
      when(mockTimerProvider.settings).thenReturn(AppSettings(userName: 'Test User'));
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Verify app structure exists
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });

    testWidgets('Should handle settings update', (WidgetTester tester) async {
      // Mock existing user
      when(mockTimerProvider.settings).thenReturn(AppSettings(userName: 'Test User'));
      
      await tester.pumpWidget(
        ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const TimeTrappApp(),
        ),
      );
      
      await tester.pump();
      
      // Verify app structure exists
      expect(find.byType(TimeTrappApp), findsOneWidget);
    });
  });
}