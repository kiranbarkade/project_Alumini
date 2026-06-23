import 'package:flutter_test/flutter_test.dart';
import 'package:zeal_alumni_portal/main.dart';

void main() {
  testWidgets('Smoke test for CareerBridgeAppScope launch', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CareerBridgeAppScope());

    // Verify that the scope compiles and builds.
    expect(find.byType(CareerBridgeAppScope), findsOneWidget);
  });
}
