import 'package:flutter_test/flutter_test.dart';
import 'package:commutr/main.dart';

void main() {
  testWidgets('CommutrApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CommutrApp());

    // Verify onboarding screen is presented
    expect(find.text('SMARTCROWD TRANSIT'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
