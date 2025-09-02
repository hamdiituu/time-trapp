// This is a basic Flutter widget test for Time Trapp app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:time_trapp/main.dart';
import 'package:time_trapp/providers/timer_provider.dart';

void main() {
  testWidgets('Time Trapp app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => TimerProvider(),
        child: const TimeTrappApp(),
      ),
    );

    // Wait for initial frame
    await tester.pump();

    // Verify that the app loads
    expect(find.byType(TimeTrappApp), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
