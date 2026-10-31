#!/usr/bin/env bash
# Generates the Android platform folder (once) and applies Bhumi Saathi settings.
set -euo pipefail

if [ ! -d android ]; then
  mkdir -p /tmp/bs_bak && cp -r lib test pubspec.yaml l10n.yaml analysis_options.yaml /tmp/bs_bak/
  flutter create --platforms=android --org in.bhumisaathi --project-name bhumi_saathi .
  rm -rf lib test && cp -r /tmp/bs_bak/lib /tmp/bs_bak/test . && cp /tmp/bs_bak/pubspec.yaml /tmp/bs_bak/l10n.yaml /tmp/bs_bak/analysis_options.yaml .
fi

   if [ -f android/app/build.gradle.kts ]; then GRADLE=android/app/build.gradle.kts; else GRADLE=android/app/build.gradle; fi
MANIFEST=android/app/src/main/AndroidManifest.xml

# applicationId must match the Firebase app: in.bhumisaathi.app
sed -i -E 's/applicationId *=? *"[^"]*"/applicationId = "in.bhumisaathi.app"/' "$GRADLE"
# Min SDK 23
sed -i -E 's/minSdk(Version)? *=? *flutter\.minSdkVersion/minSdk = 23/' "$GRADLE"

# Release: R8 shrink + obfuscation rules
cp tool/proguard-rules.pro android/app/proguard-rules.pro
if ! grep -q "proguard-rules.pro" "$GRADLE"; then
  if [[ "$GRADLE" == *.kts ]]; then
    sed -i '/signingConfig = signingConfigs.getByName("debug")/a\            isMinifyEnabled = true\n            isShrinkResources = true\n            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")' "$GRADLE"
  else
    sed -i '/signingConfig signingConfigs.debug/a\            minifyEnabled true\n            shrinkResources true\n            proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro"' "$GRADLE"
  fi
fi

# Label, INTERNET permission, and package-visibility queries (links, mail, TTS)
sed -i -E 's/android:label="[^"]*"/android:label="Bhumi Saathi"/' "$MANIFEST"
if ! grep -q "android.permission.INTERNET" "$MANIFEST"; then
  sed -i 's#<application#<uses-permission android:name="android.permission.INTERNET"/>\n    <queries>\n        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>\n        <intent><action android:name="android.intent.action.SENDTO"/><data android:scheme="mailto"/></intent>\n        <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>\n    </queries>\n    <application#' "$MANIFEST"
fi
echo "Android setup done."
