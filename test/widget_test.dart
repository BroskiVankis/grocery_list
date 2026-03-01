import 'package:flutter_test/flutter_test.dart';

import 'package:grocery_list/main.dart';

void main() {
  testWidgets('App shows landing content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Grocery shopping\nmade easy'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
