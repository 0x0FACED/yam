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

### Desktop downloads

For Linux, extract the archive into its own directory and run `bundle/yam`.
Do not move the executable away from `bundle/data/` and `bundle/lib/`. The
release is built on Ubuntu 24.04 and requires compatible system GTK3/glibc
libraries; it is not a distro package or AppImage.

The macOS archive contains both Intel and Apple Silicon executables, but has no
Apple Developer ID signature or notarization. Gatekeeper may require an explicit
allowance in Privacy & Security. Only allow a download whose source and checksum
you trust; this pipeline does not publish to the App Store.

## Project decisions

Product and architecture decisions are in [`docs/adr/`](docs/adr/). CI, signing
and version rules are recorded in [ADR 0025](docs/adr/0025-github-ci-releases-and-runtime-version.md).
The current implementation handoff is [`agents/PROJECT_STATE.md`](agents/PROJECT_STATE.md).
