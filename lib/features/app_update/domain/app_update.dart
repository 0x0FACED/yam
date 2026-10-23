/// A canonical public version and its monotonically increasing Android code.
class AppUpdateVersion {
  const AppUpdateVersion._(this.version, this.buildNumber, this._components);

  factory AppUpdateVersion.parse(String value) {
    final match = _pattern.firstMatch(value);
    if (match == null || match.end != value.length) {
      throw const FormatException('Expected MAJOR.MINOR.PATCH+BUILD.');
    }
    final components = <int>[];
    for (var index = 1; index <= 3; index++) {
      final component = int.tryParse(match.group(index)!);
      if (component == null) {
        throw const FormatException('Version component exceeds integer range.');
      }
      components.add(component);
    }
    final buildNumber = int.tryParse(match.group(4)!);
    if (buildNumber == null || buildNumber > 2100000000) {
      throw const FormatException('Android build number is out of range.');
    }
    return AppUpdateVersion._(
      '${match.group(1)}.${match.group(2)}.${match.group(3)}',
      buildNumber,
      components,
    );
  }

  static final _pattern = RegExp(
    r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\+([1-9][0-9]*)$',
  );

  final String version;
  final int buildNumber;
  final List<int> _components;

  String get displayVersion => '$version+$buildNumber';

  /// Android requires a greater code, even when the public version increases.
  bool isNewerThan(AppUpdateVersion installed) {
    if (buildNumber <= installed.buildNumber) return false;
    for (var index = 0; index < _components.length; index++) {
      if (_components[index] != installed._components[index]) {
        return _components[index] > installed._components[index];
      }
    }
    return true;
  }
}

class AppUpdateRelease {
  const AppUpdateRelease({
    required this.version,
    required this.apkName,
    required this.apkUrl,
    required this.sizeBytes,
    required this.sha256,
  });

  final AppUpdateVersion version;
  final String apkName;
  final Uri apkUrl;
  final int sizeBytes;
  final String sha256;
}

enum UpdateFailure {
  unavailable,
  network,
  rateLimited,
  invalidRelease,
  download,
  checksum,
}

class AppUpdateException implements Exception {
  const AppUpdateException(this.failure);

  final UpdateFailure failure;

  @override
  String toString() => 'AppUpdateException(${failure.name})';
}
