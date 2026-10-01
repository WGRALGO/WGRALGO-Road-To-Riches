# Changelog

All notable changes to WGRALGO Road to Riches™: Lease It or Own It or Hoof It are documented here.

## [1.0.0] — 2026-10-01

Initial public release.

- Offline Android app (native WebView, `versionCode 1`, `versionName "1.0.0"`)
  built from the WGRA website version of the game
- Starter and Real World levels, three characters, big city / suburb / small
  town, and Buy / Lease / Car-free / All three paths
- Instant feedback, tap-to-define glossary terms, and a results report with
  grades and the 5-year cost of each option
- App shell: app bar, setup-screen logo, in-app splash, slide-up Tips for
  teachers, Free help, About, Privacy, and Credits sheets; website-only social
  links and GoFundMe bar removed; Content-Security-Policy
- Android back button closes a definition or sheet; on the main screen it asks
  before exiting
- Logo, big and on black: adaptive and legacy launcher icons, Android 12+
  system splash, Android 7–11 launch screen
- No permissions, no data saved, no ads or tracking
- GitHub Actions: debug build on every push and a signed release workflow;
  `tools/validate-release.sh`
