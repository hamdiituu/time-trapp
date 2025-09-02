import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:time_trapp/main.dart' as app;
import 'package:time_trapp/providers/timer_provider.dart';
import 'package:time_trapp/models/app_settings.dart';
import 'package:time_trapp/models/task_session.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Tests', () {
    testWidgets('Complete app flow from onboarding to session completion', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Test onboarding flow
      await testOnboardingFlow(tester);
      
      // Test home screen
      await testHomeScreen(tester);
      
      // Test session creation
      await testSessionCreation(tester);
      
      // Test session completion
      await testSessionCompletion(tester);
      
      // Test reports
      await testReports(tester);
      
      // Test settings
      await testSettings(tester);
    });

    testWidgets('Session management flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if already completed
      if (find.text('Time Trapp\'a Hoş Geldiniz!').evaluate().isNotEmpty) {
        await testOnboardingFlow(tester);
      }

      // Test multiple sessions
      await testMultipleSessions(tester);
    });

    testWidgets('Webhook configuration flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Skip onboarding if already completed
      if (find.text('Time Trapp\'a Hoş Geldiniz!').evaluate().isNotEmpty) {
        await testOnboardingFlow(tester);
      }

      // Test webhook configuration
      await testWebhookConfiguration(tester);
    });
  });
}

Future<void> testOnboardingFlow(WidgetTester tester) async {
  // Verify onboarding screen is displayed
  expect(find.text('Time Trapp\'a Hoş Geldiniz!'), findsOneWidget);
  
  // Enter user name
  await tester.enterText(find.byType(TextFormField), 'Test User');
  await tester.pumpAndSettle();
  
  // Tap continue button
  await tester.tap(find.text('Devam Et'));
  await tester.pumpAndSettle();
  
  // Verify we're on home screen
  expect(find.text('Merhaba, Test User!'), findsOneWidget);
}

Future<void> testHomeScreen(WidgetTester tester) async {
  // Verify home screen elements
  expect(find.text('Başlat'), findsOneWidget);
  expect(find.text('Bugünkü Özet'), findsOneWidget);
  expect(find.text('Son Seanslar'), findsOneWidget);
  
  // Verify navigation buttons
  expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
  expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  expect(find.byIcon(Icons.more_vert), findsOneWidget);
}

Future<void> testSessionCreation(WidgetTester tester) async {
  // Tap start button
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  // Verify modal is displayed
  expect(find.text('Yeni Seans Başlat'), findsOneWidget);
  
  // Fill form
  await tester.enterText(find.byType(TextFormField).at(0), 'Development');
  await tester.enterText(find.byType(TextFormField).at(1), 'Feature Implementation');
  await tester.enterText(find.byType(TextFormField).at(2), 'https://github.com/project');
  await tester.pumpAndSettle();
  
  // Tap start button in modal
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  // Verify session started
  expect(find.text('Durdur'), findsOneWidget);
  expect(find.text('Development'), findsOneWidget);
  expect(find.text('Feature Implementation'), findsOneWidget);
}

Future<void> testSessionCompletion(WidgetTester tester) async {
  // Wait a bit to simulate work
  await tester.pump(Duration(seconds: 1));
  
  // Tap stop button
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  
  // Verify confirmation dialog
  expect(find.text('Seansı Durdur'), findsOneWidget);
  
  // Confirm stop
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  
  // Verify session stopped
  expect(find.text('Başlat'), findsOneWidget);
  expect(find.text('Henüz aktif bir seans yok'), findsOneWidget);
}

Future<void> testReports(WidgetTester tester) async {
  // Navigate to reports
  await tester.tap(find.byIcon(Icons.analytics_outlined));
  await tester.pumpAndSettle();
  
  // Verify reports screen
  expect(find.text('Raporlar'), findsOneWidget);
  expect(find.text('Günlük Rapor'), findsOneWidget);
  expect(find.text('Saatlik Rapor'), findsOneWidget);
  
  // Test daily report
  await tester.tap(find.text('Günlük Rapor Oluştur'));
  await tester.pumpAndSettle();
  
  // Go back to home
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
}

Future<void> testSettings(WidgetTester tester) async {
  // Navigate to settings
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  
  // Verify settings screen
  expect(find.text('Ayarlar'), findsOneWidget);
  expect(find.text('Kullanıcı Adı'), findsOneWidget);
  expect(find.text('Webhook Ayarları'), findsOneWidget);
  
  // Update user name
  await tester.enterText(find.byType(TextFormField), 'Updated User');
  await tester.pumpAndSettle();
  
  // Save settings
  await tester.tap(find.text('Kaydet'));
  await tester.pumpAndSettle();
  
  // Go back to home
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
  
  // Verify updated name
  expect(find.text('Merhaba, Updated User!'), findsOneWidget);
}

Future<void> testMultipleSessions(WidgetTester tester) async {
  // Create first session
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byType(TextFormField).at(0), 'First Session');
  await tester.enterText(find.byType(TextFormField).at(1), 'First Goal');
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  // Wait and stop first session
  await tester.pump(Duration(seconds: 1));
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  
  // Create second session
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  await tester.enterText(find.byType(TextFormField).at(0), 'Second Session');
  await tester.enterText(find.byType(TextFormField).at(1), 'Second Goal');
  await tester.tap(find.text('Başlat'));
  await tester.pumpAndSettle();
  
  // Wait and stop second session
  await tester.pump(Duration(seconds: 1));
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Durdur'));
  await tester.pumpAndSettle();
  
  // Verify both sessions are in history
  expect(find.text('First Session'), findsOneWidget);
  expect(find.text('Second Session'), findsOneWidget);
}

Future<void> testWebhookConfiguration(WidgetTester tester) async {
  // Navigate to settings
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  
  // Configure webhook
  await tester.enterText(find.byType(TextFormField).at(1), 'https://example.com/webhook');
  await tester.pumpAndSettle();
  
  // Select POST method
  await tester.tap(find.byType(DropdownButtonFormField<String>));
  await tester.pumpAndSettle();
  await tester.tap(find.text('POST'));
  await tester.pumpAndSettle();
  
  // Enable webhook events
  await tester.tap(find.byType(CheckboxListTile).at(0));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CheckboxListTile).at(1));
  await tester.pumpAndSettle();
  
  // Save settings
  await tester.tap(find.text('Kaydet'));
  await tester.pumpAndSettle();
  
  // Go back to home
  await tester.tap(find.byIcon(Icons.arrow_back));
  await tester.pumpAndSettle();
}
