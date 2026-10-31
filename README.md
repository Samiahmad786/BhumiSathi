# Bhumi Saathi – unified land-services helper for India

Flutter (Android first) · Riverpod · go_router · 9 languages · earthy green + saffron theme.
**Not a government app.** It opens official land-record portals inside the app and never touches CAPTCHAs/OTPs.

## Current scope (this build)
- No login / OTP / Firebase yet. Language, state, district and calculator history are stored **on the phone only**.
- Config (states, districts, terminology, unit conversions) is bundled in `assets/config/*.json`.
  Optional: set `AppConstants.remoteConfigUrl` (lib/core/constants.dart) to a hosted JSON
  `{ "states": {...}, "terminology": {...}, "units": {...} }` and data updates without a new APK.
- "Delete my data" in Profile wipes everything stored locally (Play account-deletion requirement for a no-account app).

## Build on your computer
```bash
flutter --version                 # install Flutter stable first
bash tool/setup_android.sh        # creates android/ and applies: appId in.bhumisaathi.app, minSdk 23,
                                  # INTERNET permission, R8, app label
flutter pub get
flutter gen-l10n
flutter test
flutter run                       # or: flutter build apk --release
```
APK: `build/app/outputs/flutter-apk/app-release.apk` (debug-signed, fine for testing).

## Build on GitHub (no local setup)
1. Create a GitHub repo and push this folder.
2. Actions → "Build APK" runs on every push to `main` and on tags like `v1.0.0`.
3. Download the APK from the run's **Artifacts**; tagged builds also appear under **Releases**.

## Create a release keystore (needed before Play Store)
```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Keep the `.jks` file and passwords safe (never commit; they are git-ignored). Create `android/key.properties`:
```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/full/path/to/upload-keystore.jks
```
then wire it into `android/app/build.gradle(.kts)` `signingConfigs.release` (Flutter docs: "Build and release an Android app").

## Before you publish – IMPORTANT
- `assets/config/units.json`: katha/dhur/bigha/biswa values are commonly used figures, marked `verified:false`. They vary by district. **Verify against official sources.**
- `assets/config/states.json`: portal URLs are best-known official addresses. Confirm each one and per-service deep links.
- `terminology.json`: Hindi/English complete; Bengali for West Bengal. Other languages fall back to English terms. Add `"mr"`, `"gu"` … keys to translate.
- `AppConstants.supportEmail` is a placeholder.
- Translations (ARB files) are machine-written drafts; have native speakers review them. FAQ/privacy/terms text exists in English + Hindi only (others fall back to English).
- Have a lawyer review the Privacy Policy and Terms.

## Add a state / district / unit
- State: add an object to `states.json` (+ terms in `terminology.json`, + units in `units.json -> standards`).
- District-specific units: `units.json -> standards.<state>.districtOverrides.<districtId>`.

## Phase 2 – Play Store checklist
- `flutter build appbundle --release` (signed with upload keystore); bump `version:` in pubspec.yaml (`1.0.0+1` → build number is versionCode).
- Adaptive icon + splash: add `flutter_launcher_icons` / `flutter_native_splash`.
- Play Console: Data safety form (no data collected if you stay local-only; update when you add Firebase), privacy-policy URL (host the text publicly), content rating, target audience (not for children), app description disclaimer:
  *"Bhumi Saathi is an independent app and is not affiliated with any government body. Data is shown from official public portals."*
- Add Firebase Auth/Firestore/Remote Config later: `flutterfire configure`, then add the login screens (design leaves a clean seam in `settingsProvider`).

## Structure
```
lib/
  core/ (theme, router, config, providers, widgets)
  features/ splash, onboarding, dashboard, webview, calculator, offices, profile, help
  l10n/ app_*.arb (9 languages)
assets/config/ states.json  terminology.json  units.json
test/ calculator_test.dart  language_switch_test.dart
tool/ setup_android.sh  gen_arb.py
.github/workflows/build.yml
```
