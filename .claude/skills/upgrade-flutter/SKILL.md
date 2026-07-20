---
name: upgrade-flutter
description: Use when the user asks to upgrade Flutter/Dart SDK version for this project (image_painter_rotate package + example app). Covers version pinning files, pubspec constraints, dependency upgrades, mock regeneration, verification steps, branch/PR workflow (develop vs protected main), cutting a release, and post-merge branch cleanup — the full task, not just the SDK bump.
---

# Upgrade Flutter for this project

This repo is a **Flutter package** (`project_type: package` in `.metadata`), not an app,
plus an `example/` app that consumes it via a path dependency. Both need attention.

## 0. Sync with remote and pick the right base branch

**Fetch before branching — don't trust a local `main` that hasn't been updated recently.**
This repo was renamed (`yellowQ-Flutter-Image-Painter` → `Image-Painter-Rotate`) and its
default branch changed from `main` to `develop` without local clones being notified. A
stale local `main` silently missed several commits, including an already-tagged/published
version bump — work built on top of it collided with a version that was already released.

```bash
git remote get-url origin                              # confirm it points at the current repo
gh repo view <owner>/<repo> --json defaultBranchRef     # confirm the actual default branch
git fetch origin
```

- Branch from `origin/<default-branch>` (currently `develop`), not from a possibly-stale
  local `main`.
- Before bumping `version:` in `pubspec.yaml`, check it isn't already taken:
  `git tag --list` and `git show origin/<default-branch>:pubspec.yaml | grep version:`.
  If the version you're about to write already exists, pick the next free one.
- `main` has branch protection (PR-only, requires a passing `test` status check) — direct
  `git push` to it will be rejected. `develop` currently has no branch protection.

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
  pin, so CI always runs against latest stable regardless of local pins. It only triggers
  on push/PR **to `main`** — a PR opened against `develop` gets no CI run at all, so don't
  expect a `test` check to appear there; rely on local `flutter analyze`/`test` instead.

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
Expect `flutter build apk` to print warnings if `example/android`'s Gradle/AGP/Kotlin
versions are below what the new Flutter wants — not fatal, a separate upgrade task. It may
also auto-edit `example/android/gradle.properties` (Flutter's Kotlin migrator adding
`android.builtInKotlin` / `android.newDsl` flags) — commit that, it's what a fresh build
under the new SDK produces.

A newer Dart SDK can also ship a slightly different formatter than whatever last touched
existing files — after switching versions, run `dart format .` (not just `--set-exit-if-changed`)
across the whole repo, not only files you edited, and commit any reformatting it does as
its own `style:` commit.

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

- Open the PR against the current default branch (`develop`, see step 0), not `main`.
  `main` only takes merges via PR from `develop` and won't run this repo's CI for a
  feature-branch PR anyway.
- Since PRs into `develop` get no automated `test` check (step 1), treat your local
  `flutter analyze` / `dart format --set-exit-if-changed` / `flutter test` / example-app
  build as the actual gate — run them all after any rebase, since rebasing can reintroduce
  formatting drift from a newer Dart formatter or reorder commits unexpectedly.

## 9. Merge into develop

Once the PR is `MERGEABLE`/`CLEAN` with no unresolved review comments, merge it — don't
wait for a CI check that will never appear on a `develop`-targeted PR (step 1). This user
has confirmed they want PRs merged automatically once verification is clean, without a
second round of confirmation.

## 10. Cut a release — this is part of "upgrade Flutter", not a separate ask

A Flutter-upgrade task in this repo isn't finished when the PR merges. Immediately follow
up with a release, per `GEMINI.md`'s release rules:

```bash
git fetch origin && git checkout develop && git reset --hard origin/develop
grep "^version:" pubspec.yaml          # confirm it matches what you intend to tag
head CHANGELOG.md                      # confirm the top entry matches
git tag -a vX.Y.Z -m vX.Y.Z <commit-or-just-HEAD>
git push origin vX.Y.Z
```

Pushing the tag triggers `.github/workflows/release_publish.yaml`: publishes to pub.dev,
then publishes a matching GitHub release. That workflow now (as of the CI fix below) falls
back to `gh release create --generate-notes` if no draft release already exists for the
tag, so a bare `git push origin vX.Y.Z` is sufficient — no need to pre-create a draft.
Watch the run (`gh run watch <id>`) to confirm both the pub.dev publish and the GitHub
release step actually succeed, not just that the tag push worked.

## 11. Sync main with develop

`main` lags `develop` and only advances via a `develop` → `main` PR (this repo's own
pattern — see PR #9, #10, #13). Unlike a `develop`-targeted PR, **this one does trigger
`flutter_test.yaml`'s required `test` check** (step 1) since it targets `main` — wait for
that check to go green before merging, then merge same as step 9.

```bash
gh pr create --base main --head develop --title "sync: merge develop into main"
gh run watch <run-id>              # wait for the required `test` check
gh pr merge <pr-number> --merge
```

## 12. Clean up local branches

```bash
git fetch origin --prune
git branch --merged origin/develop     # candidates for `git branch -d`
git branch -D <finished-feature-branch> <any-temp-backup-branch>
git branch -f main origin/main         # local main can go stale fast — resync it
```
