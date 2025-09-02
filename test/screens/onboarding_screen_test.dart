import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/screens/onboarding_screen.dart';
import 'package:time_trapp/providers/timer_provider.dart';

void main() {
  group('OnboardingScreen', () {
    testWidgets('should display welcome message', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('Time Trapp\'a Hoş Geldiniz!'), findsOneWidget);
      expect(find.text('Zamanınızı takip etmenin en kolay yolu. Çalışma seanslarınızı kaydedin, ilerlemenizi görün ve hedeflerinize ulaşın.'), findsOneWidget);
    });

    testWidgets('should display continue button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Assert
      expect(find.text('İleri'), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display features page', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to second page
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();

      // Assert - Should be on features page
      expect(find.text('Özellikler'), findsOneWidget);
      expect(find.text('Kolay Başlatma'), findsOneWidget);
      expect(find.text('Detaylı Raporlar'), findsOneWidget);
      expect(find.text('Webhook Desteği'), findsOneWidget);
    });

    testWidgets('should display name input page', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => TimerProvider(),
          child: const MaterialApp(
            home: OnboardingScreen(),
          ),
        ),
      );

      // Navigate to name page
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('İleri'));
      await tester.pumpAndSettle();

      // Assert - Should be on name page
      expect(find.text('Adınızı Girin'), findsOneWidget);
      expect(find.text('Başla'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
