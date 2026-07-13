import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitebox_jubin_proj/main.dart';

void main() {
  testWidgets('App landing smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that the title logo 'BITEBOX' is present.
    expect(find.text('BITEBOX'), findsWidgets);
    expect(find.text('24/7'), findsWidgets);

    // Verify home features text loads.
    expect(find.text('Bite Right.\nDay or Night.'), findsOneWidget);
  });
}
