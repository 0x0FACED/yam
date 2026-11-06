import 'dart:async';
import 'dart:convert';
import 'dart:io';

// LaunchServices makes YAM, not the IDE, responsible for macOS privacy requests.
// Attach the debugger afterwards; executing Contents/MacOS/YAM directly crashes
// on first speech authorization from VS Code (flutter/flutter#70374).
Future<void> main(List<String> arguments) async {
  if (!Platform.isMacOS || arguments.length > 1) {
    stderr.writeln('Usage on macOS: dart run tool/run_macos.dart [entrypoint]');
    exitCode = 64;
    return;
  }
  final serviceInfo = File('.dart_tool/yam-macos-vm-service.json');
  if (await serviceInfo.exists()) await serviceInfo.delete();
  final build = await Process.start('flutter', [
    'build',
    'macos',
    '--debug',
    '--target',
    arguments.isEmpty ? 'lib/main.dart' : arguments.single,
  ], mode: ProcessStartMode.inheritStdio);
  final buildStatus = await build.exitCode;
  if (buildStatus != 0) {
    exitCode = buildStatus;
    return;
  }

  final logs = await Directory.systemTemp.createTemp('yam-macos-launch-');
  final output = File('${logs.path}/stdout.log');
  final errors = File('${logs.path}/stderr.log');
  await output.create();
  await errors.create();
  final serviceUri = Completer<String>();
  var scan = Future<void>.value();
  void readOutput() {
    scan = scan
        .then((_) async {
          if (serviceUri.isCompleted) return;
          final text = await output.readAsString();
          final match = RegExp(
            r'Dart VM service is listening on (http://127\.0\.0\.1:\d+/\S+)',
            caseSensitive: false,
          ).firstMatch(text);
          if (match != null) serviceUri.complete(match.group(1)!);
        })
        .catchError((Object error, StackTrace stack) {
          if (!serviceUri.isCompleted) serviceUri.completeError(error, stack);
        });
  }

  // Redirected native stdout does not reliably emit Dart file-watch events.
  final discovery = Timer.periodic(
    const Duration(milliseconds: 100),
    (_) => readOutput(),
  );
  try {
    final launched = await Process.run('/usr/bin/open', [
      '-n',
      '--stdout',
      output.path,
      '--stderr',
      errors.path,
      'build/macos/Build/Products/Debug/YAM.app',
    ]);
    if (launched.exitCode != 0) {
      throw ProcessException(
        '/usr/bin/open',
        const [],
        '${launched.stderr}',
        launched.exitCode,
      );
    }
    readOutput();
    final uri = await serviceUri.future.timeout(const Duration(seconds: 45));
    await serviceInfo.parent.create(recursive: true);
    await serviceInfo.writeAsString(jsonEncode({'uri': uri}));
    stdout.writeln(
      'YAM launched through LaunchServices. Ready for Flutter attach.',
    );
  } on Object catch (error) {
    stderr.writeln('Cannot start the macOS debug session: $error');
    stderr.writeln('Native startup logs: ${logs.path}');
    exitCode = 1;
  } finally {
    discovery.cancel();
    await scan;
    // Keep the launch logs for this running app; stdout/stderr belong to it.
  }
}
