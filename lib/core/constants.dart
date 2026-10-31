class LangOption {
  final String code;
  final String nativeName;
  final String ttsLocale;
  const LangOption(this.code, this.nativeName, this.ttsLocale);
}

class AppConstants {
  /// TODO: replace with your real support address before release.
  static const supportEmail = 'support@example.com';

  /// Optional: URL of a JSON file {"states":{...},"terminology":{...},"units":{...}}
  /// with the same shape as assets/config/*.json. Leave empty to use bundled data only.
  static const remoteConfigUrl = '';

  static const languages = <LangOption>[
    LangOption('hi', 'हिन्दी', 'hi-IN'),
    LangOption('en', 'English', 'en-IN'),
    LangOption('bn', 'বাংলা', 'bn-IN'),
    LangOption('mr', 'मराठी', 'mr-IN'),
    LangOption('gu', 'ગુજરાતી', 'gu-IN'),
    LangOption('pa', 'ਪੰਜਾਬੀ', 'pa-IN'),
    LangOption('or', 'ଓଡ଼ିଆ', 'or-IN'),
    LangOption('ta', 'தமிழ்', 'ta-IN'),
    LangOption('te', 'తెలుగు', 'te-IN'),
  ];
}
