# WGRALGO Road to Riches™: Lease It or Own It or Hoof It

**Version: 1.0.0**

A free, fully-offline Android transportation and wealth game from
**WGRALGO / The Wealth Gap Resolution Algorithm™ Inc.**

Your ride is one of your biggest monthly costs. Buy a car, lease one, or go
car-free — make the real decisions, dodge the traps, and see what each choice
costs over 5 years.

## Features

- Two levels: **Starter** (ages 14–18, hints and worked math) and **Real World**
  (adults, no hints, the math is scored)
- Three characters with different incomes, savings, credit, and commutes
- Big city, suburb, or small town (no public transit in the small town)
- Four paths: **Buy a car** (9 decisions), **Lease a car** (5), **Go car-free**
  (5), or **All three** to compare everything
- Real decisions and traps: car budget, new vs. used, where to get a loan and
  how long, the out-the-door price, dealer tricks, insurance, lease mileage and
  fine print, transit passes, the last mile, and commuter benefits
- Instant feedback after every choice, with the math explained
- Tap any underlined term for a plain-English definition
- Results report: grades for Budget, Deal Smarts, Scam Defense, and Long-Term
  Wealth, plus the 5-year total cost of each option
- Native-style app: app bar, big logo on the launcher icon and splash screen,
  slide-up Tips for teachers, Free help, About, Privacy, and Credits
- No ads, no tracking, no accounts, no internet

## Screenshots

Captured from v1.0.0 at phone size (393dp wide).

| Home | Decision | Feedback |
|------|----------|----------|
| ![Home screen](screenshots/02-home.png) | ![A decision step](screenshots/03-step.png) | ![Feedback after a choice](screenshots/04-feedback.png) |

| Definition | Results | Menu |
|------------|---------|------|
| ![Glossary definition](screenshots/05-definition.png) | ![Results report](screenshots/06-results.png) | ![Menu](screenshots/08-menu.png) |

## Offline & Privacy

Road to Riches runs fully offline. It requests **no Android permissions**,
including no `INTERNET` permission. It does not collect personal data, show
ads, use analytics or trackers, require an account, or save anything on the
device. See [PRIVACY.md](PRIVACY.md).

## Install / Sideload

1. Download `WGRALGO-RoadToRiches-v1.0.0.apk` from the
   [Releases page](../../releases).
2. On your Android device, allow **Install unknown apps** for your browser or
   file manager.
3. Open the APK and tap **Install**.

Verify the download with the `.sha256` file attached to the release:
`sha256sum -c WGRALGO-RoadToRiches-v1.0.0.apk.sha256`

Release signing certificate (`CN=WGRALGO, OU=Road to Riches`), SHA-256 fingerprint:

`06:72:0B:63:4E:B1:23:AD:FF:85:BC:DE:47:0A:BE:E6:89:42:23:3C:6A:B1:34:FE:BF:E5:1A:38:2A:3A:86:B8`

## How to Build

Requirements: JDK 17, Android SDK (platform 34, build-tools 34). No other
dependencies: the app is a single offline WebView.

```bash
./gradlew assembleDebug      # app/build/outputs/apk/debug/app-debug.apk
./gradlew assembleRelease    # signed if a keystore is configured
bash tools/validate-release.sh [path/to/app.apk]
```

For a signed release, create `keystore.properties` at the project root
(git-ignored), or set the `RTR_KEYSTORE_FILE`, `RTR_KEYSTORE_PASSWORD`,
`RTR_KEY_ALIAS`, and `RTR_KEY_PASSWORD` environment variables:

```
storeFile=/absolute/path/to/release.keystore
storePassword=********
keyAlias=********
keyPassword=********
```

### Publishing a release from GitHub

The **Android Signed Release** workflow (`.github/workflows/release.yml`)
builds, signs, validates, and publishes the APK to GitHub Releases. It reads
the keystore from repository secrets (Settings → Secrets and variables →
Actions): `RTR_KEYSTORE_BASE64` (the keystore, base64-encoded),
`RTR_KEYSTORE_PASSWORD`, `RTR_KEY_ALIAS`, and `RTR_KEY_PASSWORD`. Bump
`versionCode` / `versionName` in `app/build.gradle` and the version in the
About sheet, add a CHANGELOG entry and `release-notes/v<version>.md`, then run
the workflow from the Actions tab on `main`.

## Project Structure

```
app/src/main/assets/www/index.html   (the whole game: HTML, CSS, JS)
app/src/main/assets/www/logo.jpg
app/src/main/java/com/wgra/roadtoriches/MainActivity.java
app/src/main/res/                    (launcher icon, splash screen, theme)
tools/validate-release.sh            (release checks)
.github/workflows/                   (debug build on every push, signed release)
release-notes/
```

## Disclaimer

For education only — not financial or legal advice. All numbers are examples;
real prices, rates, insurance, fares, and laws vary by place and change over
time. For free, trustworthy help, see consumerfinance.gov, consumer.ftc.gov,
and nhtsa.gov/recalls.

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE).

## Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md).
