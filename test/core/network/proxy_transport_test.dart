import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/network/proxy_settings.dart';
import 'package:yam/core/network/proxy_settings_controller.dart';
import 'package:yam/core/network/proxy_transport.dart';

import 'proxy_fixture.dart';

void main() {
  final controllers = <ProxySettingsController>[];
  final clients = <HttpClient>[];
  final fixtures = <ProxyFixture>[];
  final servers = <HttpServer>[];
  ProxySettingsController controller({
    MemoryProxyStorage? storage,
    SecurityContext? trust,
    Duration timeout = const Duration(seconds: 2),
  }) {
    final value = ProxySettingsController(
      storage: storage ?? MemoryProxyStorage(),
      securityContext: trust,
      handshakeTimeout: timeout,
    );
    controllers.add(value);
    return value;
  }

  HttpClient client(ProxySettingsController controller) {
    final value = controller.createHttpClient();
    clients.add(value);
    return value;
  }

  Future<ProxyFixture> proxy(
    ProxyProtocol protocol, {
    bool secure = false,
  }) async {
    final value = await ProxyFixture.start(
      protocol,
      context: secure ? fixtureServerContext() : null,
    );
    fixtures.add(value);
    return value;
  }

  Future<HttpServer> origin({
    bool tls = false,
    InternetAddress? address,
  }) async {
    final value = tls
        ? await HttpServer.bindSecure(
            address ?? InternetAddress.loopbackIPv4,
            0,
            fixtureServerContext(),
          )
        : await HttpServer.bind(address ?? InternetAddress.loopbackIPv4, 0);
    servers.add(value);
    value.listen((request) {
      request.response.headers.set('x-origin', 'real');
      request.response.write('forwarded:${request.uri.path}');
      unawaited(request.response.close());
    });
    return value;
  }

  Future<String> get(HttpClient client, Uri uri) async {
    final response = await (await client.getUrl(uri)).close();
    return utf8.decoder.bind(response).join();
  }

  Uri target(
    HttpServer server, {
    bool tls = false,
    String host = '127.0.0.1',
  }) => Uri(
    scheme: tls ? 'https' : 'http',
    host: host,
    port: server.port,
    path: '/stream',
  );

  tearDown(() async {
    for (final value in clients) {
      value.close(force: true);
    }
    for (final value in controllers) {
      value.dispose();
    }
    for (final value in fixtures) {
      await value.close();
    }
    for (final value in servers) {
      await value.close(force: true);
    }
    clients.clear();
    controllers.clear();
    fixtures.clear();
    servers.clear();
  });

  for (final protocol in ProxyProtocol.values) {
    for (final authenticated in [false, true]) {
      test(
        '$protocol forwards HTTP with auth=$authenticated and fragmented replies',
        () async {
          final server = await origin();
          final tunnel = await proxy(
            protocol,
            secure: protocol == ProxyProtocol.https,
          );
          tunnel.fragment = true;
          if (authenticated) {
            tunnel.username = protocol == ProxyProtocol.socks5
                ? 'al:ice'
                : 'alice';
            tunnel.password = 'pässword';
          }
          final state = controller(trust: fixtureTrustedContext());
          await state.save(
            tunnel.settings(
              username: tunnel.username,
              password: tunnel.password,
            ),
          );
          expect(await get(client(state), target(server)), 'forwarded:/stream');
          expect(tunnel.destinations, ['127.0.0.1']);
          if (protocol != ProxyProtocol.socks5) {
            expect(
              tunnel.authorizations.single.contains('Basic '),
              authenticated,
            );
          }
        },
      );
    }

    test(
      '$protocol rejects wrong proxy credentials without reaching origin',
      () async {
        final server = await origin();
        final tunnel = await proxy(
          protocol,
          secure: protocol == ProxyProtocol.https,
        );
        tunnel.username = 'alice';
        tunnel.password = 'correct';
        final state = controller(trust: fixtureTrustedContext());
        await state.save(
          tunnel.settings(username: 'alice', password: 'wrong-secret'),
        );
        final operation = get(client(state), target(server));
        await expectLater(
          operation,
          throwsA(
            isA<ProxySettingsException>().having(
              (e) => e.code,
              'code',
              'authentication',
            ),
          ),
        );
        expect(tunnel.destinations, isEmpty);
      },
    );

    test('$protocol validates target TLS through the actual tunnel', () async {
      final server = await origin(tls: true);
      final tunnel = await proxy(
        protocol,
        secure: protocol == ProxyProtocol.https,
      );
      final trusted = controller(trust: fixtureTrustedContext());
      await trusted.save(tunnel.settings());
      expect(
        await get(client(trusted), target(server, tls: true)),
        'forwarded:/stream',
      );
      final untrusted = controller();
      await untrusted.save(tunnel.settings());
      await expectLater(
        get(client(untrusted), target(server, tls: true)),
        throwsA(isA<ProxySettingsException>()),
      );
    });

    test('$protocol never falls back to direct after proxy refusal', () async {
      final server = await origin();
      final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = closed.port;
      await closed.close();
      final state = controller();
      await state.save(
        ProxySettings(
          enabled: true,
          protocol: protocol,
          host: '127.0.0.1',
          port: port,
        ),
      );
      await expectLater(
        get(client(state), target(server)),
        throwsA(isA<ProxySettingsException>()),
      );
    });
  }

  test(
    'SOCKS sends unresolved domain to proxy rather than local resolver',
    () async {
      final server = await origin();
      final tunnel = await proxy(ProxyProtocol.socks5);
      final state = controller();
      await state.save(tunnel.settings());
      expect(
        await get(client(state), target(server, host: 'remote.invalid')),
        'forwarded:/stream',
      );
      expect(tunnel.destinations, ['remote.invalid']);
      expect(tunnel.addressTypes, [3]);
    },
  );

  test(
    'SOCKS supports literal IPv6 and a fragmented IPv6 bound reply',
    () async {
      final server = await origin(address: InternetAddress.loopbackIPv6);
      final tunnel = await proxy(ProxyProtocol.socks5);
      tunnel.boundAddressType = 4;
      tunnel.fragment = true;
      final state = controller();
      await state.save(tunnel.settings());
      expect(
        await get(client(state), target(server, host: '::1')),
        'forwarded:/stream',
      );
      expect(tunnel.addressTypes, [4]);
    },
  );

  for (final bytes in [
    <int>[],
    [5],
    [4, 0],
    [5, 255],
    [5, 0, 5, 0, 0, 9],
    [5, 0, 5, 1, 0, 1],
    [5, 0, 5, 0, 0, 1, 127],
  ]) {
    test('SOCKS rejects EOF/bad response $bytes', () async {
      final tunnel = await proxy(ProxyProtocol.socks5);
      tunnel.rawReply = bytes;
      tunnel.fragment = true;
      final state = controller();
      await state.save(tunnel.settings());
      await expectLater(
        get(client(state), Uri.parse('http://remote.invalid:8080/')),
        throwsA(isA<ProxySettingsException>()),
      );
    });
  }

  for (final response in [
    '',
    'HTTP/1.1 200 OK\r\n',
    'garbage\r\n\r\n',
    'HTTP/1.1 200 OK\r\nnot-a-header\r\n\r\n',
    'HTTP/1.1 403 Denied\r\n\r\n',
    'HTTP/1.1 200 OK\r\nX-Large: ${'x' * 16400}\r\n\r\n',
  ]) {
    test(
      'CONNECT rejects malformed, oversized or denied response (${response.length})',
      () async {
        final tunnel = await proxy(ProxyProtocol.http);
        tunnel.rawReply = latin1.encode(response);
        final state = controller();
        await state.save(tunnel.settings());
        await expectLater(
          get(client(state), Uri.parse('http://remote.invalid:8080/')),
          throwsA(isA<ProxySettingsException>()),
        );
      },
    );
  }

  for (final protocol in [ProxyProtocol.http, ProxyProtocol.socks5]) {
    test('$protocol preserves bytes coalesced after handshake', () async {
      final server = await origin();
      final tunnel = await proxy(protocol);
      tunnel.targetPrefix = ascii.encode('hello');
      final transport = ProxyTransport();
      final task = await transport.connect(target(server), tunnel.settings());
      final socket = await task.socket;
      try {
        expect(
          utf8.decode(await socket.expand((bytes) => bytes).take(5).toList()),
          'hello',
        );
      } finally {
        socket.destroy();
        await transport.closeRoutes();
      }
    });
  }

  test(
    'HTTPS proxy rejects an untrusted proxy even for a plain origin',
    () async {
      final server = await origin();
      final tunnel = await proxy(ProxyProtocol.https, secure: true);
      final state = controller();
      await state.save(tunnel.settings());
      await expectLater(
        get(client(state), target(server)),
        throwsA(isA<ProxySettingsException>()),
      );
      expect(tunnel.destinations, isEmpty);
    },
  );

  test(
    'target TLS hostname validation is not replaced by proxy trust',
    () async {
      final server = await origin(tls: true);
      final tunnel = await proxy(ProxyProtocol.https, secure: true);
      final state = controller(trust: fixtureTrustedContext());
      await state.save(tunnel.settings());
      await expectLater(
        get(client(state), target(server, tls: true, host: 'remote.invalid')),
        throwsA(isA<ProxySettingsException>()),
      );
      expect(tunnel.destinations, ['remote.invalid']);
    },
  );

  test(
    'settings change retires old direct and proxy pools in an existing client',
    () async {
      final server = await origin();
      final first = await proxy(ProxyProtocol.http);
      final second = await proxy(ProxyProtocol.socks5);
      final state = controller();
      final existing = client(state);
      expect(await get(existing, target(server)), 'forwarded:/stream');
      await state.save(first.settings());
      expect(await get(existing, target(server)), 'forwarded:/stream');
      expect(first.connections, 1);
      await state.save(second.settings());
      expect(await get(existing, target(server)), 'forwarded:/stream');
      expect(second.connections, 1);
      expect(first.connections, 1);
      await state.save(const ProxySettings());
      expect(await get(existing, target(server)), 'forwarded:/stream');
      expect(second.connections, 1);
    },
  );

  test('ConnectionTask cancellation destroys a stalled handshake', () async {
    final tunnel = await proxy(ProxyProtocol.http);
    tunnel.stall = true;
    final transport = ProxyTransport();
    final task = await transport.connect(
      Uri.parse('https://remote.invalid/'),
      tunnel.settings(),
    );
    final expectation = expectLater(
      task.socket,
      throwsA(isA<ProxySettingsException>()),
    );
    await tunnel.accepted.future;
    task.cancel();
    await expectation;
    await tunnel.disconnected.future;
    transport.closeRoutes();
  });

  test('TLS handshake cancellation destroys the lower proxy socket', () async {
    final tunnel = await proxy(ProxyProtocol.http);
    tunnel.stall = true;
    final transport = ProxyTransport();
    final task = await transport.connect(
      Uri.parse('https://remote.invalid/'),
      ProxySettings(
        enabled: true,
        protocol: ProxyProtocol.https,
        host: '127.0.0.1',
        port: tunnel.port,
      ),
    );
    final expectation = expectLater(
      task.socket,
      throwsA(isA<ProxySettingsException>()),
    );
    await tunnel.accepted.future;
    task.cancel();
    await expectation;
    await tunnel.disconnected.future;
    transport.closeRoutes();
  });

  test(
    'cancellation during nested target TLS closes both tunnel layers',
    () async {
      final origin = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final accepted = Completer<void>(), closed = Completer<void>();
      final sockets = <Socket>[];
      origin.listen((socket) {
        sockets.add(socket);
        accepted.complete();
        unawaited(socket.drain<void>().whenComplete(() => closed.complete()));
      });
      final tunnel = await proxy(ProxyProtocol.https, secure: true);
      final transport = ProxyTransport(
        securityContext: fixtureTrustedContext(),
      );
      try {
        final task = await transport.connect(
          Uri.parse('https://127.0.0.1:${origin.port}/'),
          tunnel.settings(),
        );
        final failure = expectLater(
          task.socket,
          throwsA(isA<ProxySettingsException>()),
        );
        await accepted.future;
        task.cancel();
        await failure;
        await closed.future;
      } finally {
        await transport.closeRoutes();
        for (final socket in sockets) {
          socket.destroy();
        }
        await origin.close();
      }
    },
  );

  test('tunnel fixture closes origin when the client resets TCP', () async {
    final sourceServer = await RawServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final originServer = await ServerSocket.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final sourceAccepted = sourceServer.first;
    final input = await Socket.connect('127.0.0.1', sourceServer.port);
    final source = await sourceAccepted;
    final originAccepted = originServer.first;
    final target = await Socket.connect('127.0.0.1', originServer.port);
    final origin = await originAccepted;
    final closed = origin.drain<void>();
    try {
      final failure = expectLater(
        FixturePeer(input).forward(target),
        throwsA(isA<SocketException>()),
      );
      // Closing with unread incoming data sends TCP RST rather than FIN.
      final reset = source.firstWhere((event) => event == RawSocketEvent.read);
      input.add([1]);
      await input.flush();
      await reset;
      await source.close();
      await failure;
      await closed;
    } finally {
      input.destroy();
      target.destroy();
      origin.destroy();
      await source.close();
      await sourceServer.close();
      await originServer.close();
    }
  });

  test('handshakes have a finite deadline', () async {
    final tunnel = await proxy(ProxyProtocol.http);
    tunnel.stall = true;
    final state = controller(timeout: const Duration(milliseconds: 80));
    await state.save(tunnel.settings());
    await expectLater(
      get(client(state), Uri.parse('http://remote.invalid/')),
      throwsA(
        isA<ProxySettingsException>().having((e) => e.code, 'code', 'timeout'),
      ),
    );
  });

  test(
    'changing settings cancels pending handshakes before reusing the client',
    () async {
      final server = await origin();
      final tunnel = await proxy(ProxyProtocol.http);
      tunnel.stall = true;
      final state = controller();
      await state.save(tunnel.settings());
      final existing = client(state);
      final pending = get(existing, target(server));
      final failure = expectLater(
        pending,
        throwsA(isA<ProxySettingsException>()),
      );
      await tunnel.accepted.future;
      await state.save(const ProxySettings());
      await failure;
      await tunnel.disconnected.future;
      expect(await get(existing, target(server)), 'forwarded:/stream');
    },
  );

  test(
    'streaming response is delivered before the origin finishes and can abort',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      servers.add(server);
      final finish = Completer<void>();
      server.listen((request) async {
        request.response.bufferOutput = false;
        request.response.headers.contentType = ContentType(
          'text',
          'event-stream',
        );
        request.response.write('data: first\n\n');
        await request.response.flush();
        await finish.future;
        await request.response.close();
      });
      final tunnel = await proxy(ProxyProtocol.socks5);
      final state = controller();
      await state.save(tunnel.settings());
      final http = client(state);
      final request = await http.getUrl(target(server));
      final response = await request.close();
      final first = Completer<String>();
      final subscription = utf8.decoder.bind(response).listen((data) {
        if (!first.isCompleted) first.complete(data);
      }, onError: (Object _) {});
      try {
        expect(await first.future, contains('data: first'));
        http.close(force: true);
        await subscription.cancel();
      } finally {
        finish.complete();
      }
    },
  );
}
