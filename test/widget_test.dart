// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:help_desk_data_portal/main.dart';

void main() {
  testWidgets('renders the CSV export page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('CSV Data Export'), findsOneWidget);
    expect(find.text('Export as CSV'), findsOneWidget);
    expect(find.text('284 Records Selected'), findsOneWidget);
  });
}
