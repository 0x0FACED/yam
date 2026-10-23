import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/features/app_update/data/github_update_client.dart';
import 'package:yam/features/app_update/domain/app_update.dart';

Matcher failsWith(UpdateFailure failure) => throwsA(
  isA<AppUpdateException>().having(
    (error) => error.failure,
    'failure',
    failure,
  ),
);

void main() {
  late _ReleaseServer server;
  late GitHubUpdateClient client;
  late Directory directory;

  setUp(() async {
    server = await _ReleaseServer.start();
    client = GitHubUpdateClient(apiBase: server.base);
    directory = await Directory.systemTemp.createTemp('yam-update-test-');
  });

  tearDown(() async {
    client.close();
    await server.close();
    await directory.delete(recursive: true);
  });

  test('resolves a stable release and the exact APK checksum', () async {
    final release = await client.latest();
    expect(release.version.displayVersion, '0.10.0+42');
    expect(release.apkName, _ReleaseServer.apkName);
    expect(release.apkUrl, server.assetUri(_ReleaseServer.apkName));
    expect(release.sizeBytes, server.payload.length);
    expect(release.sha256, sha256.convert(server.payload).toString());
  });

  final malformedReleases = <String, void Function(_ReleaseServer)>{
    'draft': (server) => server.metadata['draft'] = true,
    'prerelease': (server) => server.metadata['prerelease'] = true,
    'unpublished': (server) => server.metadata['published_at'] = null,
    'noncanonical tag': (server) => server.metadata['tag_name'] = '0.10.0',
    'tag mismatch': (server) => server.metadata['tag_name'] = 'v0.11.0',
    'leading zero build': (server) =>
        server.assets.first['name'] = 'yam-0.10.0+042-android.apk',
    'build overflow': (server) =>
        server.assets.first['name'] = 'yam-0.10.0+2100000001-android.apk',
    'incorrect APK name': (server) =>
        server.assets.first['name'] = 'another-0.10.0+42-android.apk',
    'missing APK version': (server) =>
        server.assets.first['name'] = 'yam-android.apk',
    'duplicate APK': (server) => server.assets.add({...server.assets.first}),
    'missing checksums': (server) => server.assets.removeLast(),
    'duplicate checksums': (server) =>
        server.assets.add({...server.assets.last}),
    'incomplete asset upload': (server) => server.assets.first['state'] = 'new',
    'noninteger asset size': (server) => server.assets.first['size'] = '1024',
    'empty asset': (server) => server.assets.first['size'] = 0,
    'foreign repository': (server) =>
        server.assets.first['browser_download_url'] = server.base
            .resolve(
              '/someone/else/releases/download/v0.10.0/${_ReleaseServer.apkName}',
            )
            .toString(),
    'checksum from another release': (server) =>
        server.assets.last['browser_download_url'] = server.base
            .resolve('/0x0FACED/yam/releases/download/v0.9.0/SHA256SUMS')
            .toString(),
    'external asset host': (server) => server.assets.first['browser_download_url'] =
        'https://github.com.evil.example/0x0FACED/yam/releases/download/v0.10.0/${_ReleaseServer.apkName}',
    'embedded credentials': (server) =>
        server.assets.first['browser_download_url'] = server
            .assetUri(_ReleaseServer.apkName)
            .replace(userInfo: 'secret')
            .toString(),
    'missing checksum entry': (server) =>
        server.setChecksums('${'0' * 64}  other.apk\n'),
    'malformed checksum': (server) =>
        server.setChecksums('not-a-sha256  ${_ReleaseServer.apkName}\n'),
    'duplicate checksum entry': (server) =>
        server.setChecksums('${server.checksums}${server.checksums}'),
    'corrupt unrelated checksum line': (server) =>
        server.setChecksums('${server.checksums}corrupt metadata\n'),
    'path instead of exact filename': (server) =>
        server.setChecksums('${'0' * 64}  subdir/${_ReleaseServer.apkName}\n'),
  };
  for (final entry in malformedReleases.entries) {
    test('rejects ${entry.key} without a fallback', () async {
      entry.value(server);
      await expectLater(
        client.latest(),
        failsWith(UpdateFailure.invalidRelease),
      );
    });
  }

  test('accepts sha256sum binary notation and uppercase digest', () async {
    server.setChecksums(
      '${sha256.convert(server.payload).toString().toUpperCase()} *${_ReleaseServer.apkName}\r\n',
    );
    final release = await client.latest();
    expect(release.sha256, sha256.convert(server.payload).toString());
  });

  test('bounds release metadata before parsing it', () async {
    server.apiBody = ' ' * (1024 * 1024 + 1);
    await expectLater(client.latest(), failsWith(UpdateFailure.invalidRelease));
  });

  test('bounds checksum metadata', () async {
    server.setChecksums(' ' * (128 * 1024 + 1));
    await expectLater(client.latest(), failsWith(UpdateFailure.invalidRelease));
  });

  final statuses = [
    (404, <String, String>{}, '', UpdateFailure.unavailable),
    (403, {'x-ratelimit-remaining': '0'}, '', UpdateFailure.rateLimited),
    (403, {'retry-after': '60'}, '', UpdateFailure.rateLimited),
    (
      403,
      <String, String>{},
      'Secondary rate limit',
      UpdateFailure.rateLimited,
    ),
    (429, <String, String>{}, '', UpdateFailure.rateLimited),
    (403, <String, String>{}, 'Forbidden', UpdateFailure.network),
    (500, <String, String>{}, '', UpdateFailure.network),
  ];
  for (final (status, headers, message, failure) in statuses) {
    test('maps HTTP $status ($message) to ${failure.name}', () async {
      server.apiStatus = status;
      server.apiHeaders.addAll(headers);
      server.apiBody = jsonEncode({'message': message});
      await expectLater(client.latest(), failsWith(failure));
    });
  }

  test(
    'streams an APK with progress and publishes only its verified file',
    () async {
      final release = await client.latest();
      final progress = <int>[];
      final file = await client.download(
        release,
        directory,
        onProgress: (received, total) {
          expect(total, server.payload.length);
          progress.add(received);
        },
      );
      expect(file.path, '${directory.path}/${_ReleaseServer.apkName}');
      expect(await file.readAsBytes(), server.payload);
      expect(progress.first, 0);
      expect(progress.last, server.payload.length);
      for (var index = 1; index < progress.length; index++) {
        expect(progress[index], greaterThan(progress[index - 1]));
      }
      expect(await File('${file.path}.part').exists(), isFalse);
      expect(await directory.list().toList(), hasLength(1));
    },
  );

  test('rejects a bad hash and keeps a previous verified APK intact', () async {
    final release = await client.latest();
    final previous = File('${directory.path}/${release.apkName}');
    await previous.writeAsBytes([1, 2, 3]);
    server.downloadPayload = [...server.payload]..[0] = 255;
    await expectLater(
      client.download(release, directory, onProgress: (_, _) {}),
      failsWith(UpdateFailure.checksum),
    );
    expect(await previous.readAsBytes(), [1, 2, 3]);
    expect(await File('${previous.path}.part').exists(), isFalse);
  });

  test(
    'rejects a truncated chunked APK and deletes its partial file',
    () async {
      final release = await client.latest();
      server.downloadPayload = server.payload.sublist(0, 16 * 1024);
      server.omitContentLength = true;
      await expectLater(
        client.download(release, directory, onProgress: (_, _) {}),
        failsWith(UpdateFailure.checksum),
      );
      expect(await directory.list().toList(), isEmpty);
    },
  );

  test('stops an oversized chunked APK and deletes its partial file', () async {
    final release = await client.latest();
    server.downloadPayload = [...server.payload, 1, 2, 3];
    server.omitContentLength = true;
    await expectLater(
      client.download(release, directory, onProgress: (_, _) {}),
      failsWith(UpdateFailure.checksum),
    );
    expect(await directory.list().toList(), isEmpty);
  });

  test('maps a failed APK response and removes the partial file', () async {
    final release = await client.latest();
    server.apkStatus = 500;
    await expectLater(
      client.download(release, directory, onProgress: (_, _) {}),
      failsWith(UpdateFailure.download),
    );
    expect(await directory.list().toList(), isEmpty);
  });

  test('maps an interrupted stream and deletes its partial file', () async {
    final release = await client.latest();
    server.disconnect = true;
    await expectLater(
      client.download(release, directory, onProgress: (_, _) {}),
      failsWith(UpdateFailure.download),
    );
    expect(await directory.list().toList(), isEmpty);
  });

  test(
    'rejects an external asset redirect before contacting its host',
    () async {
      final release = await client.latest();
      server.apkRedirect = 'https://github.com.evil.example/asset.apk';
      await expectLater(
        client.download(release, directory, onProgress: (_, _) {}),
        failsWith(UpdateFailure.invalidRelease),
      );
      expect(await directory.list().toList(), isEmpty);
    },
  );

  test('follows a confined asset redirect', () async {
    final release = await client.latest();
    server.apkRedirect = '${release.apkUrl}?download=1';
    final file = await client.download(
      release,
      directory,
      onProgress: (_, _) {},
    );
    expect(await file.readAsBytes(), server.payload);
  });

  test(
    'does not accept a path-traversing release supplied by a caller',
    () async {
      final release = await client.latest();
      final invalid = AppUpdateRelease(
        version: release.version,
        apkName: '../${release.apkName}',
        apkUrl: release.apkUrl,
        sizeBytes: release.sizeBytes,
        sha256: release.sha256,
      );
      await expectLater(
        client.download(invalid, directory, onProgress: (_, _) {}),
        failsWith(UpdateFailure.invalidRelease),
      );
      expect(await directory.list().toList(), isEmpty);
    },
  );

  test('only allows the production API or an explicit loopback test API', () {
    for (final base in [
      'http://api.github.com',
      'https://api.github.com.evil.example',
      'https://api.github.com:8443',
      'https://secret@api.github.com',
      'https://api.github.com/another/path',
      'http://192.168.1.1',
    ]) {
      expect(
        () => GitHubUpdateClient(apiBase: Uri.parse(base)),
        throwsArgumentError,
        reason: base,
      );
    }
  });
}

class _ReleaseServer {
  _ReleaseServer(this._server) {
    checksums = '${sha256.convert(payload)}  $apkName\n';
    assets = [
      {
        'name': apkName,
        'state': 'uploaded',
        'size': payload.length,
        'browser_download_url': assetUri(apkName).toString(),
      },
      {
        'name': 'SHA256SUMS',
        'state': 'uploaded',
        'size': utf8.encode(checksums).length,
        'browser_download_url': assetUri('SHA256SUMS').toString(),
      },
    ];
    metadata = {
      'tag_name': 'v0.10.0',
      'draft': false,
      'prerelease': false,
      'published_at': '2026-10-01T12:00:00Z',
      'assets': assets,
    };
    _server.listen(_serve);
  }

  static const apkName = 'yam-0.10.0+42-android.apk';
  final HttpServer _server;
  final payload = List<int>.generate(96 * 1024, (index) => index % 251);
  final apiHeaders = <String, String>{};
  late String checksums;
  late List<Map<String, Object?>> assets;
  late Map<String, Object?> metadata;
  int apiStatus = 200;
  String? apiBody;
  int apkStatus = 200;
  List<int>? downloadPayload;
  bool omitContentLength = false;
  bool disconnect = false;
  String? apkRedirect;

  Uri get base => Uri(scheme: 'http', host: '127.0.0.1', port: _server.port);

  Uri assetUri(String name) => base.replace(
    pathSegments: ['0x0FACED', 'yam', 'releases', 'download', 'v0.10.0', name],
  );

  static Future<_ReleaseServer> start() async =>
      _ReleaseServer(await HttpServer.bind(InternetAddress.loopbackIPv4, 0));

  void setChecksums(String value) {
    checksums = value;
    assets.last['size'] = utf8.encode(value).length;
  }

  Future<void> _serve(HttpRequest request) async {
    final response = request.response;
    if (request.uri.path == '/repos/0x0FACED/yam/releases/latest') {
      response.statusCode = apiStatus;
      apiHeaders.forEach(response.headers.set);
      response.headers.contentType = ContentType.json;
      final bytes = utf8.encode(apiBody ?? jsonEncode(metadata));
      response.contentLength = bytes.length;
      response.add(bytes);
      await response.close();
      return;
    }
    if (request.uri.path == assetUri('SHA256SUMS').path) {
      final bytes = utf8.encode(checksums);
      response.contentLength = bytes.length;
      response.add(bytes);
      await response.close();
      return;
    }
    if (request.uri.path != assetUri(apkName).path) {
      response.statusCode = HttpStatus.notFound;
      await response.close();
      return;
    }
    if (apkRedirect != null && !request.uri.hasQuery) {
      response.statusCode = HttpStatus.found;
      response.headers.set(HttpHeaders.locationHeader, apkRedirect!);
      await response.close();
      return;
    }
    response.statusCode = apkStatus;
    if (apkStatus != HttpStatus.ok) {
      await response.close();
      return;
    }
    final bytes = downloadPayload ?? payload;
    if (disconnect) {
      final socket = await response.detachSocket(writeHeaders: false);
      socket.add(
        utf8.encode(
          'HTTP/1.1 200 OK\r\nContent-Length: ${bytes.length}\r\n'
          'Connection: close\r\n\r\n',
        ),
      );
      socket.add(bytes.sublist(0, 8192));
      await socket.flush();
      socket.destroy();
      return;
    }
    if (!omitContentLength) response.contentLength = bytes.length;
    response.bufferOutput = false;
    for (var offset = 0; offset < bytes.length; offset += 8192) {
      final end = offset + 8192 < bytes.length ? offset + 8192 : bytes.length;
      try {
        response.add(bytes.sublist(offset, end));
        await response.flush();
      } on IOException {
        // The oversized-download test deliberately cancels the response.
        return;
      }
      if (end < bytes.length) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }
    try {
      await response.close();
    } on IOException {
      // The client may reject the final chunk before the server closes.
    }
  }

  Future<void> close() async {
    await _server.close(force: true);
  }
}
