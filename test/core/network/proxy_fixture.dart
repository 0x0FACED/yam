import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:yam/core/network/proxy_settings.dart';
import 'package:yam/core/network/proxy_settings_controller.dart';

class MemoryProxyStorage implements ProxySettingsStorage {
  String? value;
  bool failRead = false, failWrite = false;
  int reads = 0;
  final readStarted = Completer<void>();
  Completer<void>? readGate, writeGate;
  @override
  Future<String?> read() async {
    reads++;
    if (!readStarted.isCompleted) readStarted.complete();
    await readGate?.future;
    if (failRead) throw StateError('sensitive storage detail');
    return value;
  }

  @override
  Future<void> write(String value) async {
    await writeGate?.future;
    if (failWrite) throw StateError('sensitive storage detail');
    this.value = value;
  }
}

SecurityContext fixtureServerContext() => SecurityContext()
  ..useCertificateChain('test/core/network/fixtures/localhost-cert.pem')
  ..usePrivateKey('test/core/network/fixtures/localhost-key.pem');
SecurityContext fixtureTrustedContext() =>
    SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificates('test/core/network/fixtures/test-ca.pem');

/// Real loopback tunnel fixture; no Flutter/test dependency. Invalid domains
/// are intentionally resolved only here, never by the client under test.
class ProxyFixture {
  ProxyFixture._(this.server, this.protocol, this.context);
  final ServerSocket server;
  final ProxyProtocol protocol;
  final SecurityContext? context;
  final Set<Socket> sockets = {};
  final List<String> destinations = [], authorizations = [];
  final List<int> addressTypes = [];
  final Completer<void> accepted = Completer<void>();
  final Completer<void> disconnected = Completer<void>();
  int boundAddressType = 1;
  String username = '', password = '';
  bool fragment = false, stall = false;
  List<int>? rawReply;
  String? replyStatus;
  List<int> targetPrefix = [];
  int connections = 0;
  int get port => server.port;

  static Future<ProxyFixture> start(
    ProxyProtocol protocol, {
    SecurityContext? context,
  }) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final fixture = ProxyFixture._(server, protocol, context);
    server.listen((socket) {
      fixture.connections++;
      if (!fixture.accepted.isCompleted) fixture.accepted.complete();
      fixture.sockets.add(socket);
      unawaited(
        fixture._serve(socket).catchError((Object _) {
          socket.destroy();
        }),
      );
    });
    return fixture;
  }

  Future<void> _send(Socket socket, List<int> bytes) async {
    if (!fragment) {
      socket.add(bytes);
      await socket.flush();
    } else {
      for (final byte in bytes) {
        socket.add([byte]);
        await socket.flush();
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
    }
  }

  Future<void> _serve(Socket socket) async {
    if (protocol == ProxyProtocol.https) {
      socket = await SecureSocket.secureServer(socket, context!);
      sockets.add(socket);
    }
    if (stall) {
      try {
        await socket.drain<void>();
      } finally {
        if (!disconnected.isCompleted) disconnected.complete();
      }
      return;
    }
    if (rawReply != null) {
      await _send(socket, rawReply!);
      await socket.close();
      return;
    }
    final peer = FixturePeer(socket);
    late String host;
    late int port;
    if (protocol == ProxyProtocol.socks5) {
      final greeting = await peer.read(2);
      final methods = await peer.read(greeting[1]);
      final method = username.isEmpty ? 0 : 2;
      if (!methods.contains(method)) {
        await _send(socket, [5, 255]);
        return socket.destroy();
      }
      await _send(socket, [5, method]);
      if (method == 2) {
        final auth = await peer.read(2);
        final user = utf8.decode(await peer.read(auth[1]));
        final length = (await peer.read(1))[0];
        final pass = utf8.decode(await peer.read(length));
        final valid = user == username && pass == password;
        await _send(socket, [1, valid ? 0 : 1]);
        if (!valid) return socket.destroy();
      }
      final request = await peer.read(4);
      addressTypes.add(request[3]);
      switch (request[3]) {
        case 1:
          host = InternetAddress.fromRawAddress(
            Uint8List.fromList(await peer.read(4)),
          ).address;
        case 4:
          host = InternetAddress.fromRawAddress(
            Uint8List.fromList(await peer.read(16)),
          ).address;
        case 3:
          host = utf8.decode(await peer.read((await peer.read(1))[0]));
        default:
          throw StateError('invalid address type');
      }
      final portBytes = await peer.read(2);
      port = portBytes[0] * 256 + portBytes[1];
      final bound = switch (boundAddressType) {
        4 => [4, ...List<int>.filled(16, 0), 0, 0],
        3 => [3, 4, ...ascii.encode('host'), 0, 0],
        _ => [1, 127, 0, 0, 1, 0, 0],
      };
      await _send(socket, [5, 0, 0, ...bound, ...targetPrefix]);
    } else {
      final bytes = <int>[];
      while (bytes.length < 16384) {
        bytes.add((await peer.read(1))[0]);
        if (bytes.length >= 4 &&
            latin1.decode(bytes.sublist(bytes.length - 4)) == '\r\n\r\n') {
          break;
        }
      }
      final lines = latin1.decode(bytes).split('\r\n');
      final authority = lines.first.split(' ')[1];
      final target = Uri.parse('http://$authority');
      host = target.host;
      port = target.port;
      final authorization =
          lines
              .where((line) => line.startsWith('Proxy-Authorization: '))
              .firstOrNull ??
          '';
      authorizations.add(authorization);
      final expected =
          'Proxy-Authorization: Basic ${base64Encode(utf8.encode('$username:$password'))}';
      final status =
          replyStatus ??
          (username.isNotEmpty && authorization != expected
              ? '407 Proxy Authentication Required'
              : '200 Connection Established');
      await _send(socket, [
        ...latin1.encode('HTTP/1.1 $status\r\n\r\n'),
        ...targetPrefix,
      ]);
      if (!status.startsWith('200')) return socket.destroy();
    }
    destinations.add(host);
    final target = await Socket.connect(
      host == 'remote.invalid' ? '127.0.0.1' : host,
      port,
    );
    sockets.add(target);
    target.listen(
      socket.add,
      onError: (Object _) => socket.destroy(),
      onDone: socket.destroy,
    );
    await peer.forward(target);
  }

  ProxySettings settings({String username = '', String password = ''}) =>
      ProxySettings(
        enabled: true,
        protocol: protocol,
        host: '127.0.0.1',
        port: port,
        username: username,
        password: password,
      );

  Future<void> close() async {
    for (final socket in sockets) {
      socket.destroy();
    }
    await server.close();
  }
}

class FixturePeer {
  FixturePeer(this.socket) : iterator = StreamIterator(socket);
  final Socket socket;
  final StreamIterator<List<int>> iterator;
  List<int> pending = [];
  int offset = 0;
  Future<List<int>> read(int count) async {
    final result = <int>[];
    while (result.length < count) {
      if (offset == pending.length) {
        if (!await iterator.moveNext()) throw StateError('fixture EOF');
        pending = iterator.current;
        offset = 0;
      }
      final needed = count - result.length;
      final available = pending.length - offset;
      final length = needed < available ? needed : available;
      result.addAll(pending.getRange(offset, offset + length));
      offset += length;
    }
    return result;
  }

  Future<void> forward(Socket target) async {
    if (offset < pending.length) target.add(pending.sublist(offset));
    while (await iterator.moveNext()) {
      target.add(iterator.current);
      await target.flush();
    }
    target.destroy();
  }
}
