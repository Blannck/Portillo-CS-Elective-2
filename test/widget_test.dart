// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that user name and balance are rendered.
    expect(find.text('Johnny Depp'), findsOneWidget);
    expect(find.text('\$98,325'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
  });
}


