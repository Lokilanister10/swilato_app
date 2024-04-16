import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swilato_app/main.dart';

void main() {
  testWidgets('Test SensorApp functionality', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp());

    // Verify that the Start Recording button is present
    expect(find.text('Start Recording'), findsOneWidget);

    // Tap the Start Recording button and trigger a frame.
    await tester.tap(find.text('Start Recording'));
    await tester.pump();

    // Verify that the Stop Recording button is present after starting recording
    expect(find.text('Stop Recording'), findsOneWidget);

    // Tap the Stop Recording button and trigger a frame.
    await tester.tap(find.text('Stop Recording'));
    await tester.pump();

    // Verify that the Start Recording button is present again after stopping recording
    expect(find.text('Start Recording'), findsOneWidget);
  });
}
