import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bhumi_saathi/core/providers.dart';
import 'package:bhumi_saathi/features/onboarding/language_screen.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';

class _TestApp extends ConsumerWidget {
  const _TestApp();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.lang));
    return MaterialApp(
      locale: Locale(lang ?? 'en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LanguageScreen(first: true),
    );
  }
}

void main() {
  testWidgets('UI switches language instantly and saves the choice', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const _TestApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('हिन्दी'));
    await tester.pumpAndSettle();
    expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
    expect(prefs.getString('lang'), 'hi');

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    expect(find.text('உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்'), findsOneWidget);
  });
}
