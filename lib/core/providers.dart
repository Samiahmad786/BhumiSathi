import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/config_models.dart';
import 'constants.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((_) => throw UnimplementedError());
final appConfigProvider = Provider<AppConfig>((_) => throw UnimplementedError());

class Settings {
  final String? lang, stateId, districtId;
  final bool readAloud;
  const Settings({this.lang, this.stateId, this.districtId, this.readAloud = false});
  bool get hasLocation => stateId != null && districtId != null;
  Settings copyWith({String? lang, String? stateId, String? districtId, bool? readAloud}) => Settings(
        lang: lang ?? this.lang,
        stateId: stateId ?? this.stateId,
        districtId: districtId ?? this.districtId,
        readAloud: readAloud ?? this.readAloud,
      );
}

class SettingsNotifier extends Notifier<Settings> {
  late SharedPreferences _p;

  @override
  Settings build() {
    _p = ref.watch(sharedPrefsProvider);
    return Settings(
      lang: _p.getString('lang'),
      stateId: _p.getString('state'),
      districtId: _p.getString('district'),
      readAloud: _p.getBool('tts') ?? false,
    );
  }

  Future<void> setLang(String code) async {
    state = state.copyWith(lang: code);
    await _p.setString('lang', code);
  }

  Future<void> setLocation(String stateId, String districtId) async {
    state = state.copyWith(stateId: stateId, districtId: districtId);
    await _p.setString('state', stateId);
    await _p.setString('district', districtId);
  }

  Future<void> setReadAloud(bool v) async {
    state = state.copyWith(readAloud: v);
    await _p.setBool('tts', v);
  }

  /// "Delete my data": wipes everything stored on this phone.
  Future<void> clearAll() async {
    await _p.clear();
    state = const Settings();
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, Settings>(SettingsNotifier.new);

/// Language used for config lookups (falls back to English before first choice).
final langProvider = Provider<String>((ref) => ref.watch(settingsProvider).lang ?? 'en');

class TtsService {
  final FlutterTts _tts = FlutterTts();
  Future<void> speak(String text, String langCode) async {
    final loc = AppConstants.languages
        .firstWhere((l) => l.code == langCode, orElse: () => AppConstants.languages[1])
        .ttsLocale;
    try {
      await _tts.setLanguage(loc);
      await _tts.speak(text);
    } catch (_) {/* optional feature: ignore failures */}
  }
}

final ttsProvider = Provider<TtsService>((_) => TtsService());
