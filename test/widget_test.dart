import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/main.dart';

void main() {
  testWidgets('travel app renders generator screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TravelApp());

    expect(find.text('Travel Planner'), findsOneWidget);
    expect(find.text('Generate plan'), findsOneWidget);
  });
}
