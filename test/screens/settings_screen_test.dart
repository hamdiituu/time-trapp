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
      when(mockTimerProvider.updateSettings(any)).thenAnswer((_) async => {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TimerProvider>.value(
          value: mockTimerProvider,
          child: const SettingsScreen(),
        ),
      );
    }

    testWidgets('should display settings title', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Ayarlar'), findsOneWidget);
    });

    testWidgets('should display user name section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Kullanıcı Adı'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display current user name', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(userName: 'Test User'),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('should display webhook section', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Webhook Ayarları'), findsOneWidget);
    });

    testWidgets('should display webhook URL field', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Webhook URL'), findsOneWidget);
    });

    testWidgets('should display webhook method dropdown', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('HTTP Method'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should display webhook event checkboxes', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Seans Başladığında'), findsOneWidget);
      expect(find.text('Seans Bittiğinde'), findsOneWidget);
      expect(find.text('Uygulama Açıldığında'), findsOneWidget);
      expect(find.text('Uygulama Kapandığında'), findsOneWidget);
      expect(find.byType(CheckboxListTile), findsNWidgets(4));
    });

    testWidgets('should display data sending options', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Veri Gönderme'), findsOneWidget);
      expect(find.text('Body\'de Gönder'), findsOneWidget);
      expect(find.text('Query Parametrelerinde Gönder'), findsOneWidget);
      expect(find.byType(RadioListTile<bool>), findsNWidgets(2));
    });

    testWidgets('should display test webhook button', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Webhook Test Et'), findsOneWidget);
    });

    testWidgets('should display save button', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Kaydet'), findsOneWidget);
    });

    testWidgets('should update user name when text field changes', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.enterText(find.byType(TextFormField), 'New User Name');
      await tester.pump();

      // Assert
      expect(find.text('New User Name'), findsOneWidget);
    });

    testWidgets('should show webhook URL when configured', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(
          webhookConfig: WebhookConfig(
            url: 'https://example.com/webhook',
            method: 'POST',
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('https://example.com/webhook'), findsOneWidget);
    });

    testWidgets('should show selected HTTP method', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(
          webhookConfig: WebhookConfig(
            url: 'https://example.com/webhook',
            method: 'PUT',
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('PUT'), findsOneWidget);
    });

    testWidgets('should show checked webhook events', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(
          webhookConfig: WebhookConfig(
            url: 'https://example.com/webhook',
            onStart: true,
            onStop: true,
            onAppOpen: false,
            onAppClose: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final checkboxes = find.byType(CheckboxListTile);
      expect(checkboxes, findsNWidgets(4));

      // Check first two checkboxes are checked
      final firstCheckbox = tester.widget<CheckboxListTile>(checkboxes.at(0));
      final secondCheckbox = tester.widget<CheckboxListTile>(checkboxes.at(1));
      expect(firstCheckbox.value, isTrue);
      expect(secondCheckbox.value, isTrue);
    });

    testWidgets('should show selected data sending option', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(
        AppSettings(
          webhookConfig: WebhookConfig(
            url: 'https://example.com/webhook',
            sendDataInBody: false,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      final radioTiles = find.byType(RadioListTile<bool>);
      expect(radioTiles, findsNWidgets(2));

      // Check second radio is selected (query parameters)
      final secondRadio = tester.widget<RadioListTile<bool>>(radioTiles.at(1));
      expect(secondRadio.value, isTrue);
    });

    testWidgets('should tap save button and call updateSettings', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());
      when(mockTimerProvider.updateSettings(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Kaydet'));
      await tester.pump();

      // Assert
      verify(mockTimerProvider.updateSettings(any)).called(1);
    });

    testWidgets('should tap test webhook button', (WidgetTester tester) async {
      // Arrange
      when(mockTimerProvider.settings).thenReturn(AppSettings());

      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.tap(find.text('Webhook Test Et'));
      await tester.pump();

      // Assert - Should not throw any errors
      expect(find.text('Webhook Test Et'), findsOneWidget);
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
  });
}
