import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';

/// Two steps: pick state, then district. Saved on the phone; changeable anytime from Profile.
class LocationScreen extends ConsumerStatefulWidget {
  final bool first;
  const LocationScreen({super.key, this.first = false});
  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  String? _stateId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(appConfigProvider);
    final lang = ref.watch(langProvider);
    final cs = Theme.of(context).colorScheme;
    final st = cfg.stateById(_stateId);

    final items = st == null
        ? cfg.states.map((s) => (s.id, s.name.of(lang))).toList()
        : st.districts.map((d) => (d.id, d.name.of(lang))).toList();

    return PopScope(
      canPop: _stateId == null && !widget.first,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _stateId != null) setState(() => _stateId = null);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(st == null ? l.chooseState : l.chooseDistrict),
          leading: _stateId != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _stateId = null))
              : (widget.first ? null : const BackButton()),
          automaticallyImplyLeading: false,
        ),
        body: Column(children: [
          if (st != null)
            Container(
              width: double.infinity,
              color: cs.primaryContainer,
              padding: const EdgeInsets.all(16),
              child: Text(st.name.of(lang),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: cs.onPrimaryContainer)),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final (id, name) = items[i];
                return Material(
                  color: cs.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () async {
                      if (st == null) {
                        setState(() => _stateId = id);
                      } else {
                        await ref.read(settingsProvider.notifier).setLocation(st.id, id);
                        if (context.mounted) context.go('/home');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Row(children: [
                        Expanded(
                            child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
                        Icon(Icons.chevron_right_rounded, color: cs.primary, size: 28),
                      ]),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}
