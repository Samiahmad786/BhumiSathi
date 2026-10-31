import 'package:decimal/decimal.dart';
import '../../core/config/config_models.dart';

/// A land unit defined by how many square feet it equals.
class UnitDef {
  final String id;
  final LText name;
  final Decimal sqft;
  const UnitDef(this.id, this.name, this.sqft);
  UnitDef withSqft(Decimal v) => UnitDef(id, name, v);
}

class ConversionStandard {
  final String label;
  final bool verified;
  final List<UnitDef> units;
  const ConversionStandard(this.label, this.verified, this.units);

  /// Returns a copy where the given unit ids use user-supplied sq-ft values.
  ConversionStandard withCustom(Map<String, Decimal> custom) => ConversionStandard(
      label, verified, units.map((u) => custom.containsKey(u.id) ? u.withSqft(custom[u.id]!) : u).toList());
}

class ConversionRow {
  final UnitDef unit;
  final Decimal value;
  const ConversionRow(this.unit, this.value);
}

UnitDef _unit(dynamic j) =>
    UnitDef(j['id'] as String, LText.from(j['name']), Decimal.parse(j['sqft'].toString()));

class StandardResolver {
  /// base units + state units, with optional district-level overrides from units.json.
  static ConversionStandard resolve(Map<String, dynamic> unitsJson, String? stateId, String? districtId) {
    final base = (unitsJson['base'] as List).map(_unit).toList();
    final std = (unitsJson['standards'] as Map?)?[stateId] as Map?;
    if (std == null) return ConversionStandard('General – standard', false, base);
    var label = std['label'] as String;
    var local = ((std['units'] as List?) ?? []).map(_unit).toList();
    final ov = (std['districtOverrides'] as Map?)?[districtId] as Map?;
    if (ov != null) {
      label = ov['label'] as String? ?? label;
      final m = (ov['units'] as Map?) ?? {};
      local = local
          .map((u) => m.containsKey(u.id) ? u.withSqft(Decimal.parse(m[u.id].toString())) : u)
          .toList();
    }
    return ConversionStandard(label, std['verified'] == true, [...base, ...local]);
  }
}

class CalcEngine {
  /// Parses user input; returns null for empty/invalid/negative input.
  static Decimal? parse(String s) {
    final t = s.trim().replaceAll(',', '');
    if (t.isEmpty) return null;
    try {
      final d = Decimal.parse(t);
      return d < Decimal.zero ? null : d;
    } catch (_) {
      return null;
    }
  }

  /// Converts [value] of [from] into every unit. Exact Decimal/Rational maths, rounded only at the end.
  static List<ConversionRow> convertAll(Decimal value, UnitDef from, List<UnitDef> units, {int scale = 4}) {
    final totalSqft = value * from.sqft;
    return units.map((u) {
      final v = (totalSqft / u.sqft).toDecimal(scaleOnInfinitePrecision: 10).round(scale: scale);
      return ConversionRow(u, v);
    }).toList();
  }

  /// "1234567.5" -> "12,34,567.5" (Indian digit grouping), trailing zeros trimmed.
  static String format(Decimal d) {
    var s = d.toString();
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    final parts = s.split('.');
    var intPart = parts[0];
    final neg = intPart.startsWith('-');
    if (neg) intPart = intPart.substring(1);
    if (intPart.length > 3) {
      final last3 = intPart.substring(intPart.length - 3);
      var rest = intPart.substring(0, intPart.length - 3);
      final groups = <String>[];
      while (rest.length > 2) {
        groups.insert(0, rest.substring(rest.length - 2));
        rest = rest.substring(0, rest.length - 2);
      }
      if (rest.isNotEmpty) groups.insert(0, rest);
      intPart = '${groups.join(',')},$last3';
    }
    return '${neg ? '-' : ''}$intPart${parts.length > 1 ? '.${parts[1]}' : ''}';
  }
}
