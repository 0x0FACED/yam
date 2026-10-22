import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

/// Shared native release metadata. Public versions stay suitable for all targets.
class ReleaseMetadata {
  const ReleaseMetadata._(this.version, this.buildNumber);

  factory ReleaseMetadata.fromPubspec(
    String source, {
    String? tag,
    String? buildNumberOverride,
  }) {
    final Object? document;
    try {
      document = loadYaml(source);
    } on YamlException catch (error) {
      throw FormatException('Invalid pubspec.yaml: ${error.message}');
    }
    if (document is! Map || document['version'] is! String) {
      throw const FormatException(
        'pubspec.yaml must contain a version string.',
      );
    }
    final value = document['version'] as String;
    final match = _versionPattern.firstMatch(value);
    if (match == null || match.end != value.length) {
      throw const FormatException(
        'pubspec.yaml version must be MAJOR.MINOR.PATCH+BUILD without leading zeros.',
      );
    }
    for (var component = 1; component <= 3; component++) {
      if (int.tryParse(match.group(component)!) == null) {
        throw const FormatException('Version component exceeds integer range.');
      }
    }
    final version = '${match.group(1)}.${match.group(2)}.${match.group(3)}';
    final localBuildNumber = _parseBuildNumber(match.group(4)!);
    final buildNumber = buildNumberOverride == null
        ? localBuildNumber
        : _parseBuildNumber(buildNumberOverride);
    if (tag != null && tag != 'v$version') {
      throw FormatException('Release tag must equal v$version.');
    }
    return ReleaseMetadata._(version, buildNumber);
  }

  static final _versionPattern = RegExp(
    r'^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\+([1-9][0-9]*)$',
  );
  static final _buildPattern = RegExp(r'^[1-9][0-9]*$');
  static const maxBuildNumber = 2100000000;

  final String version;
  final int buildNumber;

  String get artifactVersion => '$version+$buildNumber';
  String get tag => 'v$version';

  Map<String, String> get outputs => {
    'version': version,
    'build_number': buildNumber.toString(),
    'artifact_version': artifactVersion,
    'tag': tag,
  };

  static int _parseBuildNumber(String value) {
    final parsed = int.tryParse(value);
    if (_buildPattern.firstMatch(value)?.end != value.length ||
        parsed == null ||
        parsed > maxBuildNumber) {
      throw const FormatException(
        'Build number must be a positive decimal integer no greater than 2100000000.',
      );
    }
    return parsed;
  }
}

Future<void> main(List<String> arguments) async {
  try {
    final options = <String, String>{};
    for (var index = 0; index < arguments.length; index += 2) {
      final option = arguments[index];
      if ((option != '--tag' && option != '--build-number') ||
          index + 1 == arguments.length ||
          options.containsKey(option)) {
        throw const FormatException(
          'Usage: dart run tool/release_metadata.dart '
          '[--tag vMAJOR.MINOR.PATCH] [--build-number NUMBER]',
        );
      }
      options[option] = arguments[index + 1];
    }
    final metadata = ReleaseMetadata.fromPubspec(
      await File('pubspec.yaml').readAsString(),
      tag: options['--tag'],
      buildNumberOverride: options['--build-number'],
    );
    final outputPath = Platform.environment['GITHUB_OUTPUT'];
    if (outputPath != null && outputPath.isNotEmpty) {
      await File(outputPath).writeAsString(
        metadata.outputs.entries
            .map((entry) => '${entry.key}=${entry.value}\n')
            .join(),
        mode: FileMode.append,
        flush: true,
      );
    }
    stdout.writeln(jsonEncode(metadata.outputs));
  } on FormatException catch (error) {
    stderr.writeln('release_metadata: ${error.message}');
    exitCode = 1;
  } on FileSystemException catch (error) {
    stderr.writeln('release_metadata: ${error.message}');
    exitCode = 1;
  }
}
