import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/release_metadata.dart';

String pubspecVersion(String version) =>
    'name: yam\nversion: ${jsonEncode(version)}\n';

void main() {
  test('local build uses the single pubspec version and build number', () {
    final metadata = ReleaseMetadata.fromPubspec(pubspecVersion('12.34.56+78'));
    expect(metadata.version, '12.34.56');
    expect(metadata.buildNumber, 78);
    expect(metadata.artifactVersion, '12.34.56+78');
  });

  test('release build override changes only the build number', () {
    final metadata = ReleaseMetadata.fromPubspec(
      pubspecVersion('0.2.0+7'),
      tag: 'v0.2.0',
      buildNumberOverride: '1234',
    );
    expect(metadata.version, '0.2.0');
    expect(metadata.buildNumber, 1234);
    expect(metadata.artifactVersion, '0.2.0+1234');
  });

  test('mismatched or noncanonical release tags fail before a build', () {
    for (final tag in [
      'v0.2.1',
      '0.2.0',
      'v0.2.0+7',
      'v0.2.0-rc.1',
      'v00.2.0',
      'v0.2.0\n',
      'v0.2.0; echo unexpected',
    ]) {
      expect(
        () => ReleaseMetadata.fromPubspec(pubspecVersion('0.2.0+7'), tag: tag),
        throwsFormatException,
        reason: tag,
      );
    }
  });

  test('unsupported public version syntax cannot enter native metadata', () {
    for (final version in [
      '0.2.0',
      'v0.2.0+1',
      '00.2.0+1',
      '0.02.0+1',
      '0.2.00+1',
      '0.2.0+01',
      '0.2.0+0',
      '0.2.0-rc.1+1',
      '0.2.0+1.extra',
      '0.2.0+1\n',
      '99999999999999999999999999.2.0+1',
    ]) {
      expect(
        () => ReleaseMetadata.fromPubspec(pubspecVersion(version)),
        throwsFormatException,
        reason: version,
      );
    }
  });

  test('Android build number boundary is preserved without truncation', () {
    final metadata = ReleaseMetadata.fromPubspec(
      pubspecVersion('0.2.0+1'),
      buildNumberOverride: '2100000000',
    );
    expect(metadata.buildNumber, 2100000000);
    expect(
      () => ReleaseMetadata.fromPubspec(pubspecVersion('0.2.0+2100000001')),
      throwsFormatException,
    );
  });

  test('noncanonical and out-of-range CI build numbers are rejected', () {
    for (final build in [
      '',
      '0',
      '-1',
      '+1',
      '01',
      '1.5',
      ' 1',
      '1\n',
      '2100000001',
      '99999999999999999999999999',
      '1\nversion=9.9.9',
    ]) {
      expect(
        () => ReleaseMetadata.fromPubspec(
          pubspecVersion('0.2.0+1'),
          buildNumberOverride: build,
        ),
        throwsFormatException,
        reason: build,
      );
    }
  });

  test('CI override cannot conceal invalid local version metadata', () {
    expect(
      () => ReleaseMetadata.fromPubspec(
        pubspecVersion('0.2.0+0'),
        buildNumberOverride: '123',
      ),
      throwsFormatException,
    );
  });

  test('missing, mistyped and malformed pubspec versions fail explicitly', () {
    for (final source in [
      '',
      'name: yam',
      'version: 42',
      'version: true',
      'version: [0, 2, 0]',
      'version: [unterminated',
    ]) {
      expect(
        () => ReleaseMetadata.fromPubspec(source),
        throwsFormatException,
        reason: source,
      );
    }
  });
}
