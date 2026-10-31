import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/providers.dart';
import '../calculator/calculator_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(appConfigProvider);
    final s = ref.watch(settingsProvider);
    final lang = ref.watch(langProvider);
    final cs = Theme.of(context).colorScheme;
    final langName = AppConstants.languages
        .firstWhere((o) => o.code == lang, orElse: () => AppConstants.languages[1])
        .nativeName;
    final loc =
        '${cfg.stateById(s.stateId)?.name.of(lang) ?? ''} • ${cfg.district(s.stateId, s.districtId)?.name.of(lang) ?? ''}';

    Widget tile(IconData i, String t, {String? sub, VoidCallback? onTap, Color? color, Widget? trailing}) =>
        ListTile(
          leading: Icon(i, size: 28, color: color ?? cs.primary),
          title: Text(t, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
          subtitle: sub == null ? null : Text(sub),
          trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
          onTap: onTap,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.navProfile)),
      body: ListView(children: [
        tile(Icons.translate_rounded, l.language, sub: langName, onTap: () => context.push('/language')),
        tile(Icons.location_on_rounded, l.changeLocation, sub: loc, onTap: () => context.push('/location')),
        SwitchListTile(
          secondary: Icon(Icons.record_voice_over_rounded, size: 28, color: cs.primary),
          title: Text(l.readAloud, style: Theme.of(context).textTheme.titleMedium),
          value: s.readAloud,
          onChanged: (v) => ref.read(settingsProvider.notifier).setReadAloud(v),
        ),
        const Divider(),
        tile(Icons.support_agent_rounded, l.helpFaq, onTap: () => context.push('/help')),
        tile(Icons.privacy_tip_rounded, l.privacyPolicy, onTap: () => context.push('/privacy')),
        tile(Icons.description_rounded, l.termsOfUse, onTap: () => context.push('/terms')),
        const Divider(),
        tile(Icons.delete_forever_rounded, l.deleteMyData, color: cs.error, onTap: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l.deleteMyData),
              content: Text(l.deleteConfirm),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
                FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(l.delete)),
              ],
            ),
          );
          if (ok == true) {
            await ref.read(settingsProvider.notifier).clearAll();
            ref.invalidate(historyProvider);
            if (context.mounted) context.go('/language?first=1');
          }
        }),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('${l.appName} v1.0.0\n${l.dataSource(cfg.stateById(s.stateId)?.name.of(lang) ?? '')}',
              style: TextStyle(fontSize: 13, color: cs.outline)),
        ),
      ]),
    );
  }
}
