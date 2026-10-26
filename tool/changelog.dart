import 'dart:convert';

/// Reads the repository's Keep a Changelog release-heading contract.
class ReleaseChangelog {
  ReleaseChangelog._(this._sections, this._references);

  factory ReleaseChangelog.parse(String source) {
    final sections = <String, List<String>>{};
    final references = <String>[];
    String? current;
    String? fence;
    var fenceLength = 0;
    var inComment = false;
    var lineNumber = 0;

    void append(String line) {
      if (current != null) sections[current]!.add(line);
    }

    for (final line in const LineSplitter().convert(source)) {
      lineNumber++;
      final marker = _fence.firstMatch(line);
      if (fence != null) {
        append(line);
        if (marker != null &&
            marker.group(1)![0] == fence &&
            marker.group(1)!.length >= fenceLength &&
            marker.group(2)!.trim().isEmpty) {
          fence = null;
        }
        continue;
      }
      if (inComment) {
        append(line);
        if (line.contains('-->')) inComment = false;
        continue;
      }
      if (line.trimLeft().startsWith('<!--')) {
        append(line);
        inComment = !line.contains('-->');
        continue;
      }
      if (marker != null) {
        fence = marker.group(1)![0];
        fenceLength = marker.group(1)!.length;
        append(line);
        continue;
      }
      if (_levelTwo.hasMatch(line)) {
        final match = _release.firstMatch(line);
        if (line.trimRight() == '## [Unreleased]') {
          current = 'Unreleased';
        } else if (match != null) {
          final year = int.parse(match.group(2)!);
          final month = int.parse(match.group(3)!);
          final day = int.parse(match.group(4)!);
          final date = DateTime.utc(year, month, day);
          if (year == 0 ||
              date.year != year ||
              date.month != month ||
              date.day != day) {
            throw FormatException(
              'CHANGELOG.md:$lineNumber: invalid release date.',
            );
          }
          current = match.group(1)!;
        } else {
          throw FormatException(
            'CHANGELOG.md:$lineNumber: expected ## [Unreleased] or '
            '## [MAJOR.MINOR.PATCH] - YYYY-MM-DD.',
          );
        }
        if (sections.containsKey(current)) {
          throw FormatException(
            'CHANGELOG.md:$lineNumber: duplicate section [$current].',
          );
        }
        sections[current] = [];
      } else if (_reference.hasMatch(line)) {
        references.add(line);
      } else {
        append(line);
      }
    }
    if (fence != null || inComment) {
      throw const FormatException(
        'CHANGELOG.md contains an unclosed fence or comment.',
      );
    }
    if (sections.isEmpty || sections.keys.first != 'Unreleased') {
      throw const FormatException(
        'CHANGELOG.md must start with ## [Unreleased].',
      );
    }
    final bodies = <String, String>{};
    for (final section in sections.entries) {
      final body = section.value.join('\n').trim();
      if (section.key != 'Unreleased' && !_hasChanges(body)) {
        throw FormatException(
          'CHANGELOG.md section [${section.key}] has no changes.',
        );
      }
      bodies[section.key] = body;
    }
    return ReleaseChangelog._(Map.unmodifiable(bodies), references.join('\n'));
  }

  static final _release = RegExp(
    r'^## \[((?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*))\] - ([0-9]{4})-([0-9]{2})-([0-9]{2})\s*$',
  );
  static final _levelTwo = RegExp(r'^##(?:[ \t]|$)');
  static final _fence = RegExp(r'^ {0,3}(`{3,}|~{3,})(.*)$');
  static final _reference = RegExp(r'^ {0,3}\[[^\]]+\]:\s*\S');
  static final _comments = RegExp(r'<!--.*?-->', dotAll: true);
  static final _nonContent = RegExp(
    r'^(?:#{1,6}(?:\s|$)|`{3,}|~{3,}|(?:[-*_]\s*){3,}$)',
  );

  final Map<String, String> _sections;
  final String _references;

  String notesForVersion(String version) {
    final body = _sections[version];
    if (version == 'Unreleased' || body == null) {
      throw FormatException('CHANGELOG.md has no released section [$version].');
    }
    return _references.isEmpty ? '$body\n' : '$body\n\n$_references\n';
  }

  static bool _hasChanges(String body) => const LineSplitter()
      .convert(body.replaceAll(_comments, ''))
      .map((line) => line.trim())
      .any((line) => line.length > 1 && !_nonContent.hasMatch(line));
}
