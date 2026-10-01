#!/usr/bin/env bash
# Road to Riches — release validation.
# Usage: ./tools/validate-release.sh [path/to/app.apk]
# Exit non-zero if any check fails.
set -u
cd "$(dirname "$0")/.."

GR=app/build.gradle
VERSION=$(sed -n 's/.*versionName "\([^"]*\)".*/\1/p' $GR)
CODE=$(sed -n 's/.*versionCode \([0-9]*\).*/\1/p' $GR)
IDX=app/src/main/assets/www/index.html
RES=app/src/main/res

PASS=0
FAIL=0
ok()  { echo "  PASS  $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL  $1"; FAIL=$((FAIL+1)); }

echo "== Game =="
OUT=$(node - "$IDX" <<'NODE'
const fs = require("fs");
const h = fs.readFileSync(process.argv[2], "utf8");
const R = (ok, msg) => console.log((ok ? "PASS " : "FAIL ") + msg);
const m = h.match(/<script>\n\(function \(\) \{\n  "use strict";\n  var root = document.getElementById\("wgra-rr"\);[\s\S]*?\n\}\)\(\);\n<\/script>/);
R(!!m, "game script present");
for (const name of ["PROFILES", "AREAS", "GLOSSARY"]) R(new RegExp("var " + name + " = ").test(h), name + " data present");
R(/function renderSetup\(\)/.test(h) && /function renderResults\(\)/.test(h), "setup and results screens present");
R(/window\.onAndroidBack = function/.test(h), "Android back button hook present");
NODE
)
while IFS= read -r line; do
  case "$line" in
    PASS*) ok "${line#PASS }" ;;
    FAIL*) bad "${line#FAIL }" ;;
  esac
done <<< "$OUT"

echo "== Version $VERSION (code $CODE) =="
grep -q "v$VERSION" $IDX && ok "app shows v$VERSION" || bad "app does not show v$VERSION"
grep -q "$VERSION" README.md && ok "README mentions $VERSION" || bad "README missing $VERSION"
grep -q "\[$VERSION\]" CHANGELOG.md && ok "CHANGELOG has $VERSION" || bad "CHANGELOG missing $VERSION"
[ -f "release-notes/v$VERSION.md" ] && ok "release-notes/v$VERSION.md present" || bad "release-notes/v$VERSION.md missing"

echo "== Build config =="
grep -q 'applicationId "com.wgra.roadtoriches"' $GR && ok "appId com.wgra.roadtoriches" || bad "appId wrong"
grep -q 'debuggable false' $GR && ok "release debuggable false" || bad "release not debuggable false"
grep -q 'android.permission' app/src/main/AndroidManifest.xml && bad "manifest requests a permission" || ok "manifest requests no permissions"

echo "== Logo, icon, splash =="
for f in drawable-xxxhdpi/ic_fg.png mipmap-xxxhdpi/ic_launcher.png mipmap-xxxhdpi/ic_launcher_round.png \
         drawable-nodpi/splash_icon.jpg drawable-nodpi/splash_logo.jpg drawable/splash_window.xml; do
  [ -f "$RES/$f" ] && ok "$f present" || bad "$f missing"
done
grep -q 'windowSplashScreenAnimatedIcon' $RES/values-v31/styles.xml && ok "Android 12+ splash uses the logo" || bad "Android 12+ splash not set"
grep -q '#000000' $RES/values/colors.xml && ok "icon/splash background is black" || bad "icon/splash background not black"
[ -f app/src/main/assets/www/logo.jpg ] && ok "in-app logo present" || bad "in-app logo missing"

echo "== App privacy =="
grep -qi 'Content-Security-Policy' $IDX && ok "CSP present" || bad "CSP missing"
grep -Eqi 'href="(https?:)?//|href="/|src="https?://|@import' $IDX && bad "external link or resource in app" || ok "no external links or resources"
grep -Eqi 'gofundme\.com|facebook\.com|instagram\.com|tiktok\.com|youtube\.com|linkedin\.com' $IDX && bad "donation/social link in app" || ok "no donation or social links"
grep -Eqi 'google-analytics|googletagmanager|gtag\(|firebase|admob' $IDX && bad "analytics/ads reference" || ok "no analytics or ads"
grep -Eq 'localStorage|sessionStorage|indexedDB|document\.cookie' $IDX && bad "app stores data on device" || ok "no on-device storage"

echo "== Name and orientation =="
grep -q '<string name="app_name">WGRALGO' app/src/main/res/values/strings.xml && bad "app name under the icon starts with WGRALGO" || ok "app name under the icon has no WGRALGO prefix"
grep -q 'screenOrientation' app/src/main/AndroidManifest.xml && bad "orientation is locked" || ok "rotates freely (portrait and landscape)"
grep -q 'WGRALGO-[A-Za-z]*-v' .github/workflows/release.yml && ok "APK named WGRALGO-<AppName>-v<version>.apk" || bad "APK name not uniform"

if [ "${1:-}" != "" ] && [ -f "${1:-}" ]; then
  APK="$1"
  echo "== APK: $APK =="
  SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
  BT=$(ls -d "$SDK"/build-tools/* 2>/dev/null | sort -V | tail -1)
  if [ -x "$BT/aapt2" ]; then
    DUMP=$("$BT/aapt2" dump badging "$APK" 2>/dev/null)
    echo "$DUMP" | grep -q "versionName='$VERSION'" && ok "APK versionName $VERSION" || bad "APK versionName wrong"
    echo "$DUMP" | grep -q "versionCode='$CODE'" && ok "APK versionCode $CODE" || bad "APK versionCode wrong"
    echo "$DUMP" | grep -q "package: name='com.wgra.roadtoriches'" && ok "APK package id" || bad "APK package id wrong"
    echo "$DUMP" | grep -q "uses-permission:" && bad "APK declares a permission" || ok "APK declares no permissions"
  else
    bad "aapt2 not found"
  fi
  if [ -x "$BT/apksigner" ]; then
    CERT=$("$BT/apksigner" verify --print-certs "$APK" 2>/dev/null)
    echo "$CERT" | grep -qi "CN=Android Debug" && bad "APK signed with debug cert" || ok "APK not signed with debug cert"
    "$BT/apksigner" verify "$APK" >/dev/null 2>&1 && ok "APK signature verifies" || bad "APK signature invalid/unsigned"
  else
    bad "apksigner not found"
  fi
else
  echo "== APK checks skipped (no APK path given) =="
fi

echo
echo "RESULT: $PASS passed, $FAIL failed"
[ $FAIL -eq 0 ]
