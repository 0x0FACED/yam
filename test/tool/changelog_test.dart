import 'package:flutter_test/flutter_test.dart';

import '../../tool/changelog.dart';

void main() {
  test(
    'selects the requested version without leaking other release sections',
    () {
      final changelog = ReleaseChangelog.parse('''
# Changelog

## [Unreleased]
### Added
- Future feature.

## [1.2.10] - 2026-10-26
### Added
- Current feature.

## [1.2.1] - 2026-10-23
### Fixed
- Historical fix.
''');
      expect(
        changelog.notesForVersion('1.2.1'),
        '### Fixed\n- Historical fix.\n',
      );
      expect(
        changelog.notesForVersion('1.2.10'),
        '### Added\n- Current feature.\n',
      );
      expect(() => changelog.notesForVersion('1.2.0'), throwsFormatException);
      expect(
        () => changelog.notesForVersion('Unreleased'),
        throwsFormatException,
      );
    },
  );

  test(
    'preserves reference links while keeping the introduction out of notes',
    () {
      final changelog = ReleaseChangelog.parse('''
# Changelog
Introduction for maintainers.

## [Unreleased]

## [0.2.0] - 2026-10-26
### Changed
- Read the [migration guide][backup].

[backup]: https://example.test/backup
[0.2.0]: https://example.test/releases/v0.2.0
''');
      final notes = changelog.notesForVersion('0.2.0');
      expect(notes, contains('- Read the [migration guide][backup].'));
      expect(notes, contains('[backup]: https://example.test/backup'));
      expect(notes, isNot(contains('Introduction for maintainers.')));
      expect(notes, isNot(contains('## [Unreleased]')));
    },
  );

  test('fenced examples and comments do not create release boundaries', () {
    final changelog = ReleaseChangelog.parse('''
# Changelog
## [Unreleased]
## [0.2.0] - 2026-10-26
### Added
- A Markdown example:
````markdown
## [9.9.9] - 2099-01-01
```
[example]: this is code, not a link definition
````
~~~markdown
## [8.8.8] - 2099-01-01
~~~
<!--
## [7.7.7] - 2099-01-01
-->
- End of current changes.
## [0.1.0] - 2026-10-23
- Old changes.
''');
    final notes = changelog.notesForVersion('0.2.0');
    expect(notes, contains('## [9.9.9] - 2099-01-01'));
    expect(notes, contains('[example]: this is code, not a link definition'));
    expect(notes, contains('- End of current changes.'));
    expect(notes, isNot(contains('- Old changes.')));
    expect(() => changelog.notesForVersion('9.9.9'), throwsFormatException);
    expect(() => changelog.notesForVersion('8.8.8'), throwsFormatException);
    expect(() => changelog.notesForVersion('7.7.7'), throwsFormatException);
  });

  test('accepts CRLF, Unicode and a real leap-day release', () {
    final changelog = ReleaseChangelog.parse(
      '# Changelog\r\n## [Unreleased]\r\n\r\n'
      '## [0.2.0] - 2024-02-29\r\n### Added\r\n'
      '- Описания блюд и точные БЖУ.\r\n',
    );
    expect(
      changelog.notesForVersion('0.2.0'),
      contains('Описания блюд и точные БЖУ.'),
    );
  });

  test('duplicate versions and ambiguous release headings fail explicitly', () {
    for (final source in [
      '## [Unreleased]\n## [Unreleased]\n',
      '## [Unreleased]\n## [0.2.0] - 2026-10-26\n- First.\n'
          '## [0.2.0] - 2026-10-25\n- Second.\n',
      '## [Unreleased]\n## [v0.2.0] - 2026-10-26\n- Change.\n',
      '## [Unreleased]\n## [0.2.0+2] - 2026-10-26\n- Change.\n',
      '## [Unreleased]\n## [00.2.0] - 2026-10-26\n- Change.\n',
      '## [Unreleased]\n## [0.2.0-rc.1] - 2026-10-26\n- Change.\n',
      '## [Unreleased]\n## [0.2.0]\n- Missing date.\n',
      '## [0.2.0] - 2026-10-26\n- No Unreleased section.\n',
    ]) {
      expect(
        () => ReleaseChangelog.parse(source),
        throwsFormatException,
        reason: source,
      );
    }
  });

  test(
    'normalized impossible dates cannot masquerade as real release dates',
    () {
      for (final date in [
        '2026-02-29',
        '2026-04-31',
        '2026-00-10',
        '2026-13-01',
        '0000-01-01',
      ]) {
        expect(
          () => ReleaseChangelog.parse(
            '## [Unreleased]\n## [0.2.0] - $date\n- Change.\n',
          ),
          throwsFormatException,
          reason: date,
        );
      }
    },
  );

  test(
    'empty release sections, comments and category headings cannot be published',
    () {
      for (final body in [
        '',
        '\n',
        '### Added\n',
        '<!-- write notes later -->',
        '```\n```',
        '---',
      ]) {
        expect(
          () => ReleaseChangelog.parse(
            '## [Unreleased]\n## [0.2.0] - 2026-10-26\n$body\n',
          ),
          throwsFormatException,
          reason: body,
        );
      }
    },
  );

  test('unclosed fences and comments cannot swallow following releases', () {
    for (final body in [
      '```markdown\n- An example.',
      '<!--\n- A hidden example.',
    ]) {
      expect(
        () => ReleaseChangelog.parse(
          '## [Unreleased]\n## [0.2.0] - 2026-10-26\n$body',
        ),
        throwsFormatException,
      );
    }
  });
}
