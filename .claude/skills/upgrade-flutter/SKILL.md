---
name: upgrade-flutter
description: Use when the user asks to upgrade Flutter/Dart SDK version for this project (image_painter_rotate package + example app). Covers version pinning files, pubspec constraints, dependency upgrades, mock regeneration, and verification steps specific to this repo.
---

# Upgrade Flutter for this project

This repo is a **Flutter package** (`project_type: package` in `.metadata`), not an app,
plus an `example/` app that consumes it via a path dependency. Both need attention.

## 1. Check current state first

Version info is scattered across several files — read them before changing anything:

- `pubspec.yaml` (root): `environment.sdk` and `environment.flutter` — the package's
  **minimum supported** versions (currently `sdk: ">=3.6.1 <4.0.0"`, `flutter: ">=3.27.0"`).
- `example/pubspec.yaml`: `environment.sdk` (currently `^3.6.1`) — keep in sync with root.
- `.mise.local.toml`: `[tools] flutter = "x.y.z"` — the version `mise` activates in this
  dir. This is the only version manager used in this repo (no `fvm`).
- `.metadata`: `version.channel` / `version.revision` — **do not hand-edit this file**,
  the Flutter tool rewrites it automatically on `flutter upgrade`/`flutter create`.
- `CHANGELOG.md`: top entry often records the last Flutter/Dart bump as a `Chore:` line —
  useful to see what the last upgrade actually changed.
- `.github/workflows/flutter_test.yaml`: CI installs `channel: 'stable'` with no version
  pin, so CI always runs against latest stable regardless of local pins.

## 2. Install and switch the target Flutter version

This repo pins Flutter via `mise`:

```bash
mise install flutter@<target-version>
mise use flutter@<target-version>          # updates .mise.local.toml
```

If `mise` isn't active and a system Flutter is used directly, run `flutter upgrade`
(stable channel) or `flutter upgrade --force` to jump to a specific version.

## 3. Update pubspec constraints

Bump `environment.sdk` / `environment.flutter` in **both**:
- root `pubspec.yaml`
- `example/pubspec.yaml`

Only raise the lower bound to what's actually required by new APIs used — don't bump
speculatively past what the code needs, since this is a published package other people
depend on (pub.dev: `image_painter_rotate`) and a tight floor limits their compatibility.

## 4. Refresh dependencies

```bash
flutter pub get
(cd example && flutter pub get)
flutter pub outdated                 # survey what else could move
flutter pub upgrade --major-versions # only if you intend to bump deps too, review breaking changes
```

Dev deps to watch (from root `pubspec.yaml`): `mockito`, `build_runner`, `build_test`.
Example app deps: `open_file`, `path_provider`, `cupertino_icons`, `flutter_lints`.

## 5. Regenerate generated code

`test/image_painter_utils_test.mocks.dart` is generated via `build_runner`/`mockito`.
After any SDK or mockito bump, regenerate it:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 6. Verify (repo's own release checklist, see GEMINI.md)

```bash
flutter analyze
dart format .                        # commit if this changes anything
flutter test
(cd example && flutter test)
```

If `dart format` or `analyze` causes changes, commit them before moving on — this matches
the project's existing release-prep rule in `GEMINI.md`.

Optionally sanity-build the example app for platforms you can target
(`cd example && flutter build apk` / `flutter build ios --no-codesign`) to catch native
toolchain breakage (Android Gradle/Kotlin, iOS pods) that pure `flutter test` won't catch.

## 7. Record the change

- Add a `Chore:` line to `CHANGELOG.md` documenting the new Flutter/Dart floor
  (matches the existing style, e.g. "Chore: Upgraded environment support to Flutter
  3.38.7 and Dart 3.10.3.").
- Bump `version:` in root `pubspec.yaml` per semver (an SDK floor bump alone is usually a
  patch/minor, not major).
- Do not touch `.metadata` by hand.

## 8. Before opening a PR / release

Per `GEMINI.md`: confirm `flutter analyze` passes, `dart format .` produces no diff, and
all commits are pushed before tagging a release.
