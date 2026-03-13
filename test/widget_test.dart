// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:smart_class_check_in_learning_reflection_app/app/app.dart';

void main() {
  testWidgets('home screen shows actions', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartClassApp());
    await tester.pumpAndSettle();

    expect(find.text('Smart Class Check-in'), findsOneWidget);
    expect(find.text('Check-in'), findsOneWidget);
    expect(find.text('Finish Class'), findsOneWidget);
  });
}
