import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gebeya/app/app.dart';

void main() {
  testWidgets('Gebeya smoke test - renders app title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GebeyaApp(),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verify app renders
    expect(find.byType(GebeyaApp), findsOneWidget);
  });
}
