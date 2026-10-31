import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';

class LanguageScreen extends ConsumerWidget {
  final bool first;
  const LanguageScreen({super.key, this.first = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final current = ref.watch(settingsProvider.select((s) => s.lang));
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
          title: Text(l.chooseLanguage), automaticallyImplyLeading: !first),
      body: Column(children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: AppConstants.languages.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o = AppConstants.languages[i];
              final selected = o.code == current;
              return Material(
                color: selected ? cs.secondaryContainer : cs.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        color: selected ? cs.secondary : Colors.transparent, width: 2)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => ref.read(settingsProvider.notifier).setLang(o.code),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(children: [
                      Expanded(
                          child: Text(o.nativeName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge)),
                      if (selected) Icon(Icons.check_circle_rounded, color: cs.primary, size: 30),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: current == null
                    ? null
                    : () {
                        if (first) {
                          context.go('/location?first=1');
                        } else {
                          context.go('/profile');
                        }
                      },
                child: Text(l.continueBtn),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
