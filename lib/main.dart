import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/config/config_repository.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repo = ConfigRepository(prefs);
  final config = await repo.load();
  runApp(ProviderScope(
    overrides: [
      sharedPrefsProvider.overrideWithValue(prefs),
      appConfigProvider.overrideWithValue(config),
    ],
    child: const BhumiSaathiApp(),
  ));
  repo.refreshRemote(); // background refresh, used on next launch
}
