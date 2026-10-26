# YAM

A local-first nutrition tracker for Android, iOS, macOS and Linux. Food logging,
nutrition history, goals and weight are stored locally in SQLite. An account or
network connection is not required; Open Food Facts search is optional.


## Development

Flutter is pinned in [`.fvmrc`](.fvmrc). Use that SDK locally (directly or through
FVM); GitHub Actions reads the same pin. Application dependencies are locked in
`pubspec.lock`.

```sh
flutter pub get --enforce-lockfile
flutter gen-l10n
flutter analyze
flutter test --coverage
```

The test command runs the entire current suite without exclusions. Obsolete
prototype screenshot tests and their PNG baselines were removed with explicit
approval; behavioral widget tests, calculations, SQLite and migration tests remain.

## CI

[CI](.github/workflows/ci.yml) runs on pushes to every branch and on pull requests.
The release workflow also calls it for the tagged commit. Checks use the pinned
Flutter SDK, locked dependencies, generated localization, static analysis and the
full test suite. Pull requests do not receive release-signing secrets.

[Release](.github/workflows/release.yml) runs on pushed tags matching `v*` and
publishes only after validation, tests and all three platform builds succeed:

- Android: release-signed APK;
- Linux x64: `.tar.gz` containing the **entire** Flutter bundle;
- macOS universal: `.zip` containing the `.app`, with permissions and symlinks
  preserved;
- `SHA256SUMS` for the platform downloads.

The GitHub Release remains a draft until its downloads are uploaded. The built-in
`GITHUB_TOKEN` is sufficient; only the publishing job requests `contents: write`.
Actions must be enabled for the repository. No personal access token is required
for the workflow.

Android SDK packages are installed by invoking
`$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager` directly. The hosted image
provides the SDK, but its command-line tools directory is not assumed to be in
`PATH`.

Before macOS packaging, every bundled Mach-O must contain both `x86_64` and
`arm64`. The check uses `lipo "$binary" -verify_arch x86_64 arm64`: the input file
precedes `-verify_arch`, whose remaining arguments are architecture names.

### Android signing secrets

Before pushing a release tag, configure these repository **Actions secrets**:

| Secret                      | Value                                            |
| --------------------------- | ------------------------------------------------ |
| `ANDROID_KEYSTORE_BASE64`   | Base64 content of the permanent release keystore |
| `ANDROID_KEYSTORE_PASSWORD` | Keystore password                                |
| `ANDROID_KEY_ALIAS`         | Signing-key alias                                |
| `ANDROID_KEY_PASSWORD`      | Signing-key password                             |

Use an existing release key if the application has already been distributed.
Keep a separate offline copy of the keystore and passwords: losing the key can
prevent future updates. Do not commit private keys, passwords or `key.properties`.

If no release key exists, create it **outside this repository**, with interactive
password prompts, for example:

```sh
keytool -genkeypair -storetype JKS -keyalg RSA -keysize 3072 \
  -validity 10000 -alias yam-release -keystore /private/path/yam-release.jks
```

Secrets can be configured in GitHub Settings → Secrets and variables → Actions,
or with GitHub CLI from the repository directory:

```sh
openssl base64 -A -in /private/path/yam-release.jks | gh secret set ANDROID_KEYSTORE_BASE64
gh secret set ANDROID_KEYSTORE_PASSWORD
gh secret set ANDROID_KEY_ALIAS
gh secret set ANDROID_KEY_PASSWORD
```

The three latter commands prompt for values; do not paste passwords into shell
arguments or logs. The runner decodes the key into a private temporary file and
removes it after the Android job. Missing secrets stop release builds; there is
**no debug-key fallback**. Debug builds do not need these secrets. Local signed
release builds use the same password/alias environment variables plus an absolute
`ANDROID_KEYSTORE_PATH` pointing to the keystore, rather than Base64.

An APK signed with a new release key cannot update an installed APK signed with
another key, including an old debug build. **Export a `.yam` backup before any
uninstall/reinstall** so that nutrition history is not lost.

### Versioning and tags

[`pubspec.yaml`](pubspec.yaml) is the single source of the public version and
local build number: `MAJOR.MINOR.PATCH+BUILD`, without leading zeros. Settings and
About read actual installed package metadata, not a copy of this version in Dart.

Release tags must be exactly `vMAJOR.MINOR.PATCH` and match the public pubspec
version. Prerelease suffixes are not currently part of the native release format.
For example, for `version: 0.2.0+2`, commit/push that version change, then create
and push the matching tag yourself:

```sh
git tag v0.2.0
git push origin v0.2.0
```

A mismatched tag fails before platform builds. CI does not rewrite pubspec,
commit version bumps or create tags. To inspect or validate metadata locally:

```sh
dart run tool/release_metadata.dart
dart run tool/release_metadata.dart --tag v0.2.0 --build-number 42
```

The second command only succeeds when pubspec declares `0.2.0`. Release CI
replaces the local BUILD with its `github.run_number`; that single number and
build name are passed to Android, Linux and macOS. A rerun retains the same build
number. Keep the release workflow counter monotonic if the workflow is ever
replaced/reset; Android updates require increasing version codes. Download names
include both the resolved version and build number.

If publication fails after creating a draft, inspect/remove that incomplete
draft before rerunning. Published releases must not be silently overwritten.

A workflow fix must be committed before starting a release from that commit.
Rerunning an older failed run reuses its original workflow revision; it does not
pick up newer workflow changes from the default branch.

### In-app Android updates

Android Settings checks `0x0FACED/yam` for a stable GitHub Release on its first
opening in each app session; **Check for updates** repeats the check. The source
repository and releases must be public. No GitHub account or token is stored in
the app, and startup/local tracking never waits for this check.

Tap **Download** to stream the APK with progress. Its exact size and SHA-256 from
the same release's `SHA256SUMS` must match before **Install update** is offered.
The existing release workflow already publishes the required assets and names.
An update needs a public version at least as high as the installed one and a
strictly greater Android build number.

Installation uses Android's system confirmation. If Android asks, allow YAM to
install apps from this source, return to Settings, and tap **Install update**
again. APK package, expected version and current signing certificate are checked
before handoff; debug/release keys cannot update each other, and signing-key
rotation is not supported by this updater.

The APK stays in private, non-backed-up app storage, not Downloads. It is not
deleted merely because the installer opened: cancellation must remain retryable.
After successful package replacement, a receiver removes completed/obsolete
APKs; startup repeats this cleanup if needed and removes interrupted `.part`
downloads. A canceled newer APK remains available until installation or a later
successful update makes it obsolete.

Install the first version containing this updater manually. Future updates can
then stay entirely on the phone. This APK installation flow is Android-only;
desktop downloads below are unchanged.

### Desktop downloads

For Linux, extract the archive into its own directory and run `bundle/yam`.
Do not move the executable away from `bundle/data/` and `bundle/lib/`. The
release is built on Ubuntu 24.04 and requires compatible system GTK3/glibc
libraries; it is not a distro package or AppImage.

The macOS archive contains both Intel and Apple Silicon executables, but has no
Apple Developer ID signature or notarization. Gatekeeper may require an explicit
allowance in Privacy & Security. Only allow a download whose source and checksum
you trust; this pipeline does not publish to the App Store.

## Backup compatibility

Settings exports `.yam` archives, not raw SQLite files. This build writes backup
format v2 and imports v1/v2. Updating the app migrates its existing local database;
reinstalling or moving devices requires restoring an exported `.yam` backup.
Keep a backup before uninstalling or downgrading the app.

Starting with this importer, additional JSON fields are ignored, while missing
nullable fields default to null. Required fields, known value types, units,
relationships and archive limits are still validated before any database change.
Unknown incompatible format versions and changes to the ZIP structure are rejected.

Compatible future exporters must keep format v2 for additive optional fields and
preserve the existing required fields and their meaning. A database schema bump
does not itself require a backup-format bump. An older compatible importer only
stores fields it understands; unknown fields can be lost on re-export. This does
not retroactively change already-released strict v1 importers.

The compatibility policy is recorded in
[ADR 0030](docs/adr/0030-compatible-backup-fields.md).

## Project decisions

Product and architecture decisions are in [`docs/adr/`](docs/adr/). CI, signing
and version rules are recorded in [ADR 0025](docs/adr/0025-github-ci-releases-and-runtime-version.md).
The current implementation handoff is [`agents/PROJECT_STATE.md`](agents/PROJECT_STATE.md).
