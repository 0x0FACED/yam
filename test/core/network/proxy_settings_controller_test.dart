import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/network/proxy_settings.dart';
import 'package:yam/core/network/proxy_settings_controller.dart';

import 'proxy_fixture.dart';

void main() {
  test(
    'validation rejects injection, invalid endpoints and SOCKS byte lengths',
    () {
      for (final host in [
        '',
        'http://proxy.test',
        'proxy.test:8080',
        'proxy.test/path',
        'proxy\r\nInjected',
        ' proxy.test',
        '-proxy.test',
      ]) {
        expect(
          () => ProxySettings(enabled: true, host: host).validate(),
          throwsA(
            isA<ProxySettingsException>().having(
              (e) => e.code,
              'code',
              'invalid_host',
            ),
          ),
        );
      }
      for (final port in [0, -1, 65536]) {
        expect(
          () => ProxySettings(
            enabled: true,
            host: 'localhost',
            port: port,
          ).validate(),
          throwsA(
            isA<ProxySettingsException>().having(
              (e) => e.code,
              'code',
              'invalid_port',
            ),
          ),
        );
      }
      for (final credentials in [
        ('', 'secret'),
        ('a:b', 'secret'),
        ('a\r\nHeader', 'secret'),
        ('a', 's\x00ecret'),
      ]) {
        expect(
          () => ProxySettings(
            enabled: true,
            host: 'localhost',
            username: credentials.$1,
            password: credentials.$2,
          ).validate(),
          throwsA(
            isA<ProxySettingsException>().having(
              (e) => e.code,
              'code',
              'invalid_credentials',
            ),
          ),
        );
      }
      for (final credentials in [
        ('é' * 128, 'secret'),
        ('a', 'é' * 128),
        ('a', ''),
      ]) {
        expect(
          () => ProxySettings(
            enabled: true,
            protocol: ProxyProtocol.socks5,
            host: '::1',
            username: credentials.$1,
            password: credentials.$2,
          ).validate(),
          throwsA(isA<ProxySettingsException>()),
        );
      }
      for (final host in ['localhost', 'proxy.example', '127.0.0.1', '::1']) {
        ProxySettings(enabled: true, host: host).validate();
      }
      const ProxySettings(
        enabled: false,
        host: 'invalid endpoint',
        port: 0,
      ).validate();
      expect(
        const ProxySettings(password: 'secret').toString(),
        isNot(contains('secret')),
      );
      const ProxySettings(
        enabled: true,
        protocol: ProxyProtocol.socks5,
        host: 'localhost',
        username: 'al:ice',
        password: 'secret',
      ).validate();
      expect(const ProxySettingsException('connection'), isA<IOException>());
    },
  );

  test(
    'secure initialization gates actual requests, including direct mode',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var hits = 0;
      server.listen((request) {
        hits++;
        request.response.write('ok');
        unawaited(request.response.close());
      });
      final storage = MemoryProxyStorage()..readGate = Completer<void>();
      final state = ProxySettingsController(storage: storage);
      final client = state.createHttpClient();
      try {
        final response = client
            .getUrl(Uri.parse('http://127.0.0.1:${server.port}/'))
            .then((r) => r.close());
        await storage.readStarted.future;
        expect(hits, 0);
        expect(storage.reads, 1);
        storage.readGate!.complete();
        await (await response).drain<void>();
        expect(hits, 1);
        expect(state.initialized, true);
      } finally {
        client.close(force: true);
        state.dispose();
        await server.close(force: true);
      }
    },
  );

  test(
    'cancelling during secure initialization never sends the request',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var hits = 0;
      server.listen((request) {
        hits++;
        request.response.write('must not be sent');
        unawaited(request.response.close());
      });
      final storage = MemoryProxyStorage()..readGate = Completer<void>();
      final state = ProxySettingsController(storage: storage);
      final client = state.createHttpClient();
      try {
        final pending = client
            .getUrl(Uri.parse('http://127.0.0.1:${server.port}/'))
            .then((request) => request.close());
        final rejected = expectLater(pending, throwsA(isA<IOException>()));
        await storage.readStarted.future;
        client.close(force: true);
        storage.readGate!.complete();
        await rejected;
        expect(hits, 0);
      } finally {
        client.close(force: true);
        state.dispose();
        await server.close(force: true);
      }
    },
  );

  test(
    'read failure and malformed saved state fail closed, explicit save recovers',
    () async {
      for (final malformed in [false, true]) {
        final storage = MemoryProxyStorage()..failRead = !malformed;
        if (malformed) storage.value = '{"password":"private"}';
        final state = ProxySettingsController(storage: storage);
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        var hits = 0;
        server.listen((request) {
          hits++;
          unawaited(request.response.close());
        });
        final client = state.createHttpClient();
        final uri = Uri.parse('http://127.0.0.1:${server.port}/');
        try {
          await expectLater(
            client.getUrl(uri),
            throwsA(
              isA<ProxySettingsException>().having(
                (e) => e.code,
                'code',
                'storage',
              ),
            ),
          );
          expect(hits, 0);
          expect(state.initialized, false);
          expect(state.failureCode, 'storage');
          await state.save(const ProxySettings());
          await (await (await client.getUrl(uri)).close()).drain<void>();
          expect(hits, 1);
          expect(state.failureCode, isNull);
        } finally {
          client.close(force: true);
          state.dispose();
          await server.close(force: true);
        }
      }
    },
  );

  test(
    'failed persistence retains the active route and sanitizes storage errors',
    () async {
      final storage = MemoryProxyStorage();
      final state = ProxySettingsController(storage: storage);
      await state.initialize();
      storage.failWrite = true;
      try {
        await expectLater(
          state.save(
            const ProxySettings(
              enabled: true,
              host: 'proxy.test',
              username: 'private',
              password: 'secret',
            ),
          ),
          throwsA(
            isA<ProxySettingsException>().having(
              (e) => e.toString(),
              'safe message',
              'ProxySettingsException(storage)',
            ),
          ),
        );
        expect(state.settings.enabled, false);
        expect(state.saving, false);
        expect(state.failureCode, 'storage');
      } finally {
        state.dispose();
      }
    },
  );

  test(
    'save activates only after persistence and is serialized after initialization',
    () async {
      final storage = MemoryProxyStorage()
        ..readGate = Completer<void>()
        ..writeGate = Completer<void>();
      storage.value = jsonEncode(
        const ProxySettings(host: 'old.test').toJson(),
      );
      final state = ProxySettingsController(storage: storage);
      try {
        final initialize = state.initialize();
        final save = state.save(
          const ProxySettings(enabled: true, host: 'new.test'),
        );
        storage.readGate!.complete();
        await initialize;
        await Future<void>.delayed(Duration.zero);
        expect(state.settings.host, 'old.test');
        expect(state.saving, true);
        storage.writeGate!.complete();
        await save;
        expect(state.settings.host, 'new.test');
        final reload = ProxySettingsController(storage: storage);
        try {
          await reload.initialize();
          expect(reload.settings.host, 'new.test');
        } finally {
          reload.dispose();
        }
      } finally {
        state.dispose();
      }
    },
  );

  test(
    'concurrent saves keep persistence and effective configuration in order',
    () async {
      final storage = MemoryProxyStorage()..writeGate = Completer<void>();
      final state = ProxySettingsController(storage: storage);
      try {
        final first = state.save(
          const ProxySettings(enabled: true, host: 'first.test'),
        );
        final second = state.save(
          const ProxySettings(enabled: true, host: 'second.test'),
        );
        storage.writeGate!.complete();
        await Future.wait([first, second]);
        expect(state.settings.host, 'second.test');
        expect(jsonDecode(storage.value!)['host'], 'second.test');
      } finally {
        state.dispose();
      }
    },
  );

  test(
    'dispose cancels active initialization and cannot resurrect network access',
    () async {
      final storage = MemoryProxyStorage()..readGate = Completer<void>();
      final state = ProxySettingsController(storage: storage);
      final pending = state.initialize();
      final expectation = expectLater(
        pending,
        throwsA(isA<ProxySettingsException>()),
      );
      await Future<void>.delayed(Duration.zero);
      state.dispose();
      storage.readGate!.complete();
      await expectation;
      expect(
        () => state.createHttpClient(),
        throwsA(isA<ProxySettingsException>()),
      );
    },
  );
}
