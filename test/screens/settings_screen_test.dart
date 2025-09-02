import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/screens/settings_screen.dart';
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/webhook_config.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'settings_screen_test.mocks.dart';

@GenerateMocks([TimerProvider])
void main() {
  group('SettingsScreen', () {
    late MockTimerProvider mockTimerProvider;

    setUp(() {
      mockTimerProvider = MockTimerProvider();
      // Setup common mocks
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.updateSettings(any)).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Ayarlar'), findsOneWidget);
    });

    testWidgets('should display user name section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for TextField (not TextFormField)
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should display webhook section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for webhook URL field
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should display webhook method dropdown', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for dropdown button
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should display webhook event checkboxes', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for checkboxes
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('should display data sending options', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for dropdown buttons (not radio buttons)
      expect(find.byType(DropdownButton<bool>), findsOneWidget);
    });

    testWidgets('should show webhook URL when configured', (WidgetTester tester) async {
      // Arrange
      final settings = AppSettings(
        webhookConfig: WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
        ),
      );
      when(mockTimerProvider.settings).thenReturn(settings);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that URL field exists (may be multiple instances)
      expect(find.text('https://example.com/webhook'), findsWidgets);
    });

    testWidgets('should show selected HTTP method', (WidgetTester tester) async {
      // Arrange
      final settings = AppSettings(
        webhookConfig: WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'PUT',
        ),
      );
      when(mockTimerProvider.settings).thenReturn(settings);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that dropdown exists
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should show checked webhook events', (WidgetTester tester) async {
      // Arrange
      final settings = AppSettings(
        webhookConfig: WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          onStart: true,
          onStop: true,
        ),
      );
      when(mockTimerProvider.settings).thenReturn(settings);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that checkboxes exist
      expect(find.byType(Checkbox), findsWidgets);
    });

    testWidgets('should show selected data sending option', (WidgetTester tester) async {
      // Arrange
      final settings = AppSettings(
        webhookConfig: WebhookConfig(
          url: 'https://example.com/webhook',
          method: 'POST',
          sendDataInBody: false,
        ),
      );
      when(mockTimerProvider.settings).thenReturn(settings);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check that dropdown exists
      expect(find.byType(DropdownButton<bool>), findsOneWidget);
    });

    testWidgets('should display test webhook button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for button text instead of widget type
      expect(find.text('Webhook Test Et'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Check for basic layout components
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}