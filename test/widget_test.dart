import 'package:flutter_test/flutter_test.dart';
import 'package:saree_draping_app/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DrapeAndGlowApp());
    await tester.pump();
    expect(find.byType(DrapeAndGlowApp), findsOneWidget);
  });
}
