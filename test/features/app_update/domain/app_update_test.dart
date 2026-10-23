import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/app_update/domain/app_update.dart';

void main() {
  test('preserves the canonical public version and Android build', () {
    final version = AppUpdateVersion.parse('0.10.0+2100000000');
    expect(version.version, '0.10.0');
    expect(version.buildNumber, 2100000000);
    expect(version.displayVersion, '0.10.0+2100000000');
  });

  test('compares numeric SemVer components and requires a greater build', () {
    bool newer(String candidate, String installed) => AppUpdateVersion.parse(
      candidate,
    ).isNewerThan(AppUpdateVersion.parse(installed));

    expect(newer('0.10.0+11', '0.9.0+10'), isTrue);
    expect(newer('0.9.0+12', '0.10.0+10'), isFalse);
    expect(newer('1.0.0+11', '0.99.99+10'), isTrue);
    expect(newer('0.10.1+11', '0.10.0+10'), isTrue);
    expect(newer('0.10.0+11', '0.10.0+10'), isTrue);
    expect(newer('0.10.0+10', '0.10.0+10'), isFalse);
    expect(newer('0.11.0+10', '0.10.0+10'), isFalse);
    expect(newer('1.0.0+9', '0.10.0+10'), isFalse);
  });

  test('rejects noncanonical versions and invalid Android build codes', () {
    for (final value in [
      'v0.1.0+1',
      '0.1+1',
      '0.1.0',
      '0.1.0-beta+1',
      '00.1.0+1',
      '0.01.0+1',
      '0.1.00+1',
      '0.1.0+01',
      '0.1.0+0',
      '0.1.0+-1',
      '0.1.0+2100000001',
      '0.1.0+9999999999999999999999999999',
      '9999999999999999999999999999.1.0+1',
      '0.1.0+1\n',
      ' 0.1.0+1',
    ]) {
      expect(
        () => AppUpdateVersion.parse(value),
        throwsFormatException,
        reason: value,
      );
    }
  });
}
