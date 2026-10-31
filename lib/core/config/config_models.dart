class LText {
  final Map<String, String> _m;
  const LText(this._m);
  factory LText.from(dynamic j) =>
      LText((j as Map? ?? {}).map((k, v) => MapEntry(k.toString(), v.toString())));
  String of(String lang) => _m[lang] ?? _m['en'] ?? (_m.values.isNotEmpty ? _m.values.first : '');
}

class DistrictInfo {
  final String id;
  final LText name;
  const DistrictInfo(this.id, this.name);
}

class OfficeLink {
  final String type;
  final String url;
  const OfficeLink(this.type, this.url);
}

class StateInfo {
  final String id;
  final LText name;
  final LText portalName;
  final Map<String, String> services;
  final List<OfficeLink> offices;
  final List<DistrictInfo> districts;
  const StateInfo(this.id, this.name, this.portalName, this.services, this.offices, this.districts);

  factory StateInfo.fromJson(Map j) => StateInfo(
        j['id'] as String,
        LText.from(j['name']),
        LText.from(j['portalName']),
        (j['services'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())),
        ((j['offices'] as List?) ?? [])
            .map((o) => OfficeLink(o['type'] as String, o['url'] as String))
            .toList(),
        ((j['districts'] as List?) ?? [])
            .map((d) => DistrictInfo(d['id'] as String, LText.from(d['name'])))
            .toList(),
      );
}

class AppConfig {
  final List<StateInfo> states;
  final Map<String, dynamic> _terms;
  final Map<String, dynamic> unitsJson;
  AppConfig(this.states, this._terms, this.unitsJson);

  factory AppConfig.fromJson(Map states, Map terms, Map units) => AppConfig(
        (states['states'] as List).map((s) => StateInfo.fromJson(s as Map)).toList(),
        Map<String, dynamic>.from(terms),
        Map<String, dynamic>.from(units),
      );

  StateInfo? stateById(String? id) {
    for (final s in states) {
      if (s.id == id) return s;
    }
    return null;
  }

  DistrictInfo? district(String? stateId, String? districtId) {
    final s = stateById(stateId);
    if (s == null) return null;
    for (final d in s.districts) {
      if (d.id == districtId) return d;
    }
    return null;
  }

  /// State-specific label for a concept key (record, map, khata, mutation, revenue, office).
  String term(String? stateId, String key, String lang) {
    final st = (_terms['states'] as Map?)?[stateId] as Map?;
    final raw = st?[key] ?? (_terms['default'] as Map?)?[key];
    return LText.from(raw).of(lang);
  }
}
