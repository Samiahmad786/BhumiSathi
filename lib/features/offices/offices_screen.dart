import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../webview/web_screen.dart';

class OfficesScreen extends ConsumerWidget {
  const OfficesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(appConfigProvider);
    final s = ref.watch(settingsProvider);
    final lang = ref.watch(langProvider);
    final st = cfg.stateById(s.stateId);
    final cs = Theme.of(context).colorScheme;
    final stateName = st?.name.of(lang) ?? '';

    final tiles = <(String, IconData, String)>[];
    if (st != null) {
      tiles.add((st.portalName.of(lang), Icons.language_rounded, st.services['record'] ?? ''));
      for (final o in st.offices) {
        if (o.type == 'registry') {
          tiles.add((l.registryOffice, Icons.gavel_rounded, o.url));
        } else {
          tiles.add((cfg.term(st.id, 'office', lang), Icons.account_balance_rounded, o.url));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.officesLinks)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(stateName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        for (final t in tiles)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: cs.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: t.$3.isEmpty
                    ? null
                    : () => context.push('/web',
                        extra: WebArgs(title: t.$1, url: t.$3, stateName: stateName)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: AppColors.saffron, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.account_balance_rounded, color: AppColors.soil, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(t.$1, style: Theme.of(context).textTheme.titleMedium)),
                    Icon(Icons.chevron_right_rounded, color: cs.primary, size: 28),
                  ]),
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(l.dataSource(stateName),
            style: TextStyle(fontSize: 13, color: cs.outline)),
      ]),
    );
  }
}
