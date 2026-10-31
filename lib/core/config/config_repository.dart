import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'config_models.dart';

/// Loads config: cached remote copy -> bundled assets. Remote refresh runs in the
/// background and applies on next launch, so data updates need no new APK.
class ConfigRepository {
  static const _cacheKey = 'remote_cfg_v1';
  final SharedPreferences prefs;
  ConfigRepository(this.prefs);

  Future<AppConfig> load() async {
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        final j = jsonDecode(cached) as Map;
        return AppConfig.fromJson(j['states'] as Map, j['terminology'] as Map, j['units'] as Map);
      } catch (_) {/* fall through to bundled assets */}
    }
    final s = jsonDecode(await rootBundle.loadString('assets/config/states.json')) as Map;
    final t = jsonDecode(await rootBundle.loadString('assets/config/terminology.json')) as Map;
    final u = jsonDecode(await rootBundle.loadString('assets/config/units.json')) as Map;
    return AppConfig.fromJson(s, t, u);
  }

  Future<void> refreshRemote() async {
    if (AppConstants.remoteConfigUrl.isEmpty) return;
    try {
      final r = await http
          .get(Uri.parse(AppConstants.remoteConfigUrl))
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return;
      final j = jsonDecode(r.body) as Map;
      AppConfig.fromJson(j['states'] as Map, j['terminology'] as Map, j['units'] as Map);
      await prefs.setString(_cacheKey, r.body);
    } catch (_) {/* keep current config */}
  }
}
