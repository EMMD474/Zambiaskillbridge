import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zambia_skillbridge/app.dart';
import 'package:zambia_skillbridge/data/local/local_store.dart';
import 'package:zambia_skillbridge/state/app_state.dart';

void main() {
  testWidgets('splash leads to onboarding on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [storeProvider.overrideWithValue(LocalStore(prefs))],
      child: const SkillBridgeApp(),
    ));
    expect(find.text('Zambia SkillBridge'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Show it'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Prove it'), findsOneWidget);
  });

  testWidgets('demo client reaches the client dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [storeProvider.overrideWithValue(LocalStore(prefs))],
      child: const SkillBridgeApp(),
    ));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('I need a skilled worker'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continue as demo'));
    await tester.tap(find.text('Continue as demo'));
    await tester.pumpAndSettle();
    expect(find.text('Post a Job'), findsWidgets);
    expect(find.textContaining('right near you', findRichText: true), findsOneWidget);
  });
}
