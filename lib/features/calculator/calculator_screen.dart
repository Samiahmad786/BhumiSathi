import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bhumi_saathi/l10n/app_localizations.dart';
import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import 'calculator_logic.dart';

class HistoryNotifier extends Notifier<List<String>> {
  late SharedPreferences _p;
  @override
  List<String> build() {
    _p = ref.watch(sharedPrefsProvider);
    return _p.getStringList('calc_history') ?? [];
  }

  Future<void> add(String line) async {
    if (state.isNotEmpty && state.first == line) return;
    state = [line, ...state].take(30).toList();
    await _p.setStringList('calc_history', state);
  }

  Future<void> clear() async {
    state = [];
    await _p.remove('calc_history');
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<String>>(HistoryNotifier.new);

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});
  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  final _ctrl = TextEditingController();
  String _unitId = 'decimal';
  final Map<String, Decimal> _custom = {};
  String? _customFor;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _summary(String lang, Decimal v, UnitDef from, List<ConversionRow> rows, String stdLabel) {
    final b = StringBuffer('${CalcEngine.format(v)} ${from.name.of(lang)} ($stdLabel)\n');
    for (final r in rows) {
      b.writeln('${r.unit.name.of(lang)}: ${CalcEngine.format(r.value)}');
    }
    b.write('— Bhumi Saathi (not a government app)');
    return b.toString();
  }

  Future<void> _saveHistory(String lang, Decimal v, UnitDef from, List<ConversionRow> rows) async {
    final sq = rows.firstWhere((r) => r.unit.id == 'sqft').value;
    await ref.read(historyProvider.notifier).add(
        '${CalcEngine.format(v)} ${from.name.of(lang)} = ${CalcEngine.format(sq)} ${rows.first.unit.name.of(lang)}');
  }

  Future<void> _customDialog(ConversionStandard std, String lang) async {
    final l = AppLocalizations.of(context);
    var unit = std.units.firstWhere((u) => u.id != 'sqft', orElse: () => std.units.first);
    final tc = TextEditingController(text: unit.sqft.toString());
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: Text(l.customValue),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              value: unit.id,
              items: [
                for (final u in std.units.where((u) => u.id != 'sqft'))
                  DropdownMenuItem(value: u.id, child: Text(u.name.of(lang)))
              ],
              onChanged: (v) => setD(() {
                unit = std.units.firstWhere((u) => u.id == v);
                tc.text = unit.sqft.toString();
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tc,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: '1 ${unit.name.of(lang)} = ? ${std.units.first.name.of(lang)}'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
            FilledButton(
              onPressed: () {
                final v = CalcEngine.parse(tc.text);
                if (v != null && v > Decimal.zero) setState(() => _custom[unit.id] = v);
                Navigator.pop(ctx);
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cfg = ref.watch(appConfigProvider);
    final s = ref.watch(settingsProvider);
    final lang = ref.watch(langProvider);
    final history = ref.watch(historyProvider);
    final cs = Theme.of(context).colorScheme;

    final baseStd = StandardResolver.resolve(cfg.unitsJson, s.stateId, s.districtId);
    if (_customFor != baseStd.label) {
      _custom.clear();
      _customFor = baseStd.label;
      if (!baseStd.units.any((u) => u.id == _unitId)) _unitId = 'decimal';
    }
    final std = baseStd.withCustom(_custom);
    final from = std.units.firstWhere((u) => u.id == _unitId, orElse: () => std.units.first);
    final value = CalcEngine.parse(_ctrl.text);
    final rows = value == null ? <ConversionRow>[] : CalcEngine.convertAll(value, from, std.units);
    final stdText = _custom.isEmpty ? std.label : '${std.label} + ✎';

    return Scaffold(
      appBar: AppBar(title: Text(l.landCalculator)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextField(
          controller: _ctrl,
          autofocus: false,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
          decoration: InputDecoration(labelText: l.enterValue),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (value != null) _saveHistory(lang, value, from, rows);
          },
        ),
        const SizedBox(height: 14),
        Text(l.fromUnit, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final u in std.units)
            ChoiceChip(
              materialTapTargetSize: MaterialTapTargetSize.padded,
              visualDensity: const VisualDensity(horizontal: 1, vertical: 1),
              label: Text(u.name.of(lang), style: const TextStyle(fontSize: 16)),
              selected: u.id == from.id,
              selectedColor: cs.secondaryContainer,
              onSelected: (_) => setState(() => _unitId = u.id),
            ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.rule_rounded, color: cs.onPrimaryContainer),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(l.standardUsed(stdText),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600))),
            ]),
            if (!std.verified)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('⚠ ${l.faq2a}',
                    style: TextStyle(fontSize: 14, color: cs.onPrimaryContainer)),
              ),
            const SizedBox(height: 8),
            Wrap(spacing: 8, children: [
              OutlinedButton(onPressed: () => _customDialog(std, lang), child: Text(l.customValue)),
              if (_custom.isNotEmpty)
                TextButton(onPressed: () => setState(_custom.clear), child: Text(l.useStandard)),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        if (value != null) ...[
          Text(l.allResults, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final r in rows)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: r.unit.id == from.id ? cs.secondaryContainer : cs.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                Expanded(child: Text(r.unit.name.of(lang), style: Theme.of(context).textTheme.bodyLarge)),
                Text(CalcEngine.format(r.value),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: cs.primary)),
              ]),
            ),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.copy_rounded),
                label: Text(l.copy),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _summary(lang, value, from, rows, std.label)));
                  await _saveHistory(lang, value, from, rows);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.saffron, foregroundColor: const Color(0xFF2B1706)),
                icon: const Icon(Icons.share_rounded),
                label: Text(l.share),
                onPressed: () async {
                  await _saveHistory(lang, value, from, rows);
                  await Share.share(_summary(lang, value, from, rows, std.label));
                },
              ),
            ),
          ]),
        ],
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: Text(l.history, style: Theme.of(context).textTheme.titleLarge)),
          if (history.isNotEmpty)
            TextButton(onPressed: () => ref.read(historyProvider.notifier).clear(), child: Text(l.clearHistory)),
        ]),
        if (history.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l.noHistory, style: TextStyle(color: cs.outline, fontSize: 16)),
          ),
        for (final h in history)
          ListTile(
            leading: const Icon(Icons.history_rounded),
            title: Text(h),
            contentPadding: EdgeInsets.zero,
          ),
      ]),
    );
  }
}
