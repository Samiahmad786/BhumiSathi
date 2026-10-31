import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../webview/web_screen.dart';

class _Item {
  final String? serviceKey; // null => internal route
  final String? route;
  final String label;
  final IconData icon;
  final Color accent;
  const _Item(this.serviceKey, this.route, this.label, this.icon, this.accent);
}

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(appConfigProvider);
    final s = ref.watch(settingsProvider);
    final lang = ref.watch(langProvider);
    final st = cfg.stateById(s.stateId);
    final dist = cfg.district(s.stateId, s.districtId);
    final t = (String k) => cfg.term(s.stateId, k, lang);
    final cs = Theme.of(context).colorScheme;

    final items = <_Item>[
      _Item('record', null, t('record'), Icons.description_rounded, AppColors.forest),
      _Item('map', null, t('map'), Icons.map_rounded, AppColors.saffron),
      _Item('khata', null, t('khata'), Icons.search_rounded, AppColors.moss),
      _Item('mutation', null, t('mutation'), Icons.swap_horiz_rounded, AppColors.clay),
      _Item('revenue', null, t('revenue'), Icons.payments_rounded, AppColors.turmeric),
      _Item(null, '/calculator', l.landCalculator, Icons.calculate_rounded, AppColors.forest),
      _Item(null, '/offices', l.officesLinks, Icons.account_balance_rounded, AppColors.saffron),
      _Item(null, '/help', l.helpFaq, Icons.support_agent_rounded, AppColors.moss),
    ];

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: SizedBox(
          height: 210,
          child: Stack(fit: StackFit.expand, children: [
            const CustomPaint(
                painter: FieldPainter(
                    top: AppColors.forest,
                    bottom: AppColors.moss,
                    furrow: Colors.white,
                    sun: AppColors.saffron)),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${l.namaste} 🙏',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(l.appName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white.withOpacity(0.9))),
                  const Spacer(),
                  Material(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(30),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => context.push('/location'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.clay),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                                '${st?.name.of(lang) ?? ''} • ${dist?.name.of(lang) ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppColors.soil)),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.edit_rounded, size: 20, color: AppColors.soil),
                        ]),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.95),
          itemCount: items.length,
          itemBuilder: (_, i) => _ServiceCard(item: items[i]),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Text(l.dataSource(st?.name.of(lang) ?? ''),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.outline, fontSize: 13)),
        ),
      ),
    ]);
  }
}

class _ServiceCard extends ConsumerWidget {
  final _Item item;
  const _ServiceCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final iconFg =
        ThemeData.estimateBrightnessForColor(item.accent) == Brightness.dark ? Colors.white : AppColors.soil;
    Future<void> go() async {
      final s = ref.read(settingsProvider);
      if (s.readAloud) {
        ref.read(ttsProvider).speak(item.label, ref.read(langProvider));
      }
      if (item.route != null) {
        context.go(item.route!);
      } else {
        openService(context, ref, item.serviceKey!, item.label);
      }
    }

    return Material(
      color: dark ? item.accent.withOpacity(0.16) : Color.alphaBlend(item.accent.withOpacity(0.12), AppColors.paper),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: item.accent.withOpacity(0.45), width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: go,
        onLongPress: () => ref.read(ttsProvider).speak(item.label, ref.read(langProvider)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: item.accent, borderRadius: BorderRadius.circular(18)),
              child: Icon(item.icon, size: 34, color: iconFg),
            ),
            const Spacer(),
            Text(item.label,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.onSurface, height: 1.25)),
          ]),
        ),
      ),
    );
  }
}
