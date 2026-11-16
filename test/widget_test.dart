import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitebox_jubin_proj/main.dart';
import 'package:bitebox_jubin_proj/core/content/content_providers.dart';
import 'package:bitebox_jubin_proj/core/content/site_content_models.dart';

void main() {
  testWidgets('App landing smoke test', (WidgetTester tester) async {
    // Firebase isn't initialised in widget tests, so serve the built-in
    // defaults instead of live Firestore streams.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactInfoProvider
              .overrideWith((ref) => Stream.value(SiteDefaults.contact)),
          homeStatsProvider.overrideWith((ref) => Stream.value(null)),
          machinesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    // Verify that the title logo 'BITEBOX' is present.
    expect(find.text('BITEBOX'), findsWidgets);
    expect(find.text('24/7'), findsWidgets);

    // Verify home features text loads.
    expect(find.text('Bite Right.\nDay or Night.'), findsOneWidget);
  });
}
