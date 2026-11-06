import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'proxy_settings.dart';

/// Owns every route, including direct sockets, so changes retire pooled routes.
class ProxyTransport {
  ProxyTransport({
    this.securityContext,
    this.handshakeTimeout = const Duration(seconds: 20),
  });
  final SecurityContext? securityContext;
  final Duration handshakeTimeout;
  final Set<_Attempt> _attempts = {};

  Future<ConnectionTask<Socket>> connect(
    Uri uri,
    ProxySettings settings,
  ) async {
    final attempt = _Attempt();
    _attempts.add(attempt);
    final result = Completer<Socket>();
    void cancel() {
      attempt.cancel();
      _attempts.remove(attempt);
      if (!result.isCompleted) {
        result.completeError(const ProxySettingsException('cancelled'));
      }
    }

    final timer = Timer(handshakeTimeout, () {
      if (!result.isCompleted) {
        result.completeError(const ProxySettingsException('timeout'));
        cancel();
      }
    });
    unawaited(() async {
      try {
        final socket = await _connect(
          uri,
          settings,
          attempt,
          () => _attempts.remove(attempt),
        );
        if (attempt.cancelled) {
          socket.destroy();
        } else if (!result.isCompleted) {
          result.complete(socket);
        }
      } catch (error) {
        attempt.cancel();
        _attempts.remove(attempt);
        if (!result.isCompleted) {
          result.completeError(
            error is ProxySettingsException
                ? error
                : const ProxySettingsException('connection'),
          );
        }
      } finally {
        timer.cancel();
      }
    }());
    return ConnectionTask.fromSocket(result.future, cancel);
  }

  Future<Socket> _connect(
    Uri uri,
    ProxySettings settings,
    _Attempt attempt,
    void Function() onClosed,
  ) async {
    final host = settings.enabled ? settings.host : uri.host;
    final port = settings.enabled ? settings.port : uri.port;
    final task = await RawSocket.startConnect(host, port);
    attempt.task = task;
    if (attempt.cancelled) task.cancel();
    var raw = await task.socket;
    attempt.track(raw);
    var channel = _Channel(raw);
    if (settings.enabled && settings.protocol == ProxyProtocol.https) {
      raw = await RawSecureSocket.secure(
        raw,
        subscription: channel.detach(),
        host: settings.host,
        context: securityContext,
      );
      attempt.track(raw);
      channel = _Channel(raw);
    }
    if (settings.enabled) {
      if (settings.protocol == ProxyProtocol.socks5) {
        await _socks(channel, uri, settings);
      } else {
        await _connectTunnel(channel, uri, settings);
      }
    }
    if (uri.scheme == 'https') {
      // Dart's raw TLS transport can itself wrap a RawSecureSocket. Keeping
      // the lower handles also makes cancellation during either TLS handshake
      // destructive, not just cancellation of the returned Future.
      raw = await RawSecureSocket.secure(
        raw,
        subscription: channel.detach(),
        host: uri.host,
        context: securityContext,
      );
      attempt.track(raw);
      channel = _Channel(raw);
    }
    if (attempt.cancelled) throw const ProxySettingsException('cancelled');
    return uri.scheme == 'https'
        ? _SecureTransportSocket(channel, onClosed)
        : _TransportSocket(channel, onClosed);
  }

  Future<void> closeRoutes() async {
    final retired = _attempts.toList();
    _attempts.clear();
    for (final attempt in retired) {
      attempt.cancel();
    }
    await Future.wait([
      for (final attempt in retired)
        for (final socket in attempt.sockets) socket.close(),
    ]);
    // Let HttpClient's stream/parser close notifications evict idle routes
    // before save completes and a caller issues its next request.
    await Future<void>.delayed(Duration.zero);
  }
}

class _Attempt {
  ConnectionTask<RawSocket>? task;
  final List<RawSocket> sockets = [];
  bool cancelled = false;
  void track(RawSocket socket) {
    sockets.add(socket);
    if (cancelled) socket.close();
  }

  void cancel() {
    cancelled = true;
    task?.cancel();
    for (final socket in sockets.reversed) {
      socket.close();
    }
  }
}

Future<void> _connectTunnel(
  _Channel channel,
  Uri uri,
  ProxySettings settings,
) async {
  final host = uri.host.contains(':') ? '[${uri.host}]' : uri.host;
  final authority = '$host:${uri.port}';
  final auth = settings.username.isEmpty
      ? ''
      : 'Proxy-Authorization: Basic ${base64Encode(utf8.encode('${settings.username}:${settings.password}'))}\r\n';
  await channel.write(
    utf8.encode('CONNECT $authority HTTP/1.1\r\nHost: $authority\r\n$auth\r\n'),
  );
  // Read precisely to CRLFCRLF; any following target bytes stay in the raw
  // socket, including when the proxy coalesces its response with target data.
  final header = <int>[];
  while (header.length < 16384) {
    header.add((await channel.read(1))[0]);
    final length = header.length;
    if (length >= 4 &&
        header[length - 4] == 13 &&
        header[length - 3] == 10 &&
        header[length - 2] == 13 &&
        header[length - 1] == 10) {
      final lines = latin1.decode(header).split('\r\n');
      final match = RegExp(
        r'^HTTP/1\.[01] ([0-9]{3})(?: [\x20-\x7e]*)?$',
      ).firstMatch(lines.first);
      if (match == null ||
          lines
              .skip(1)
              .any(
                (line) =>
                    line.isNotEmpty &&
                    !RegExp(
                      r'^[!#$%&\x27*+.^_`|~0-9A-Za-z-]+:[\x09\x20-\x7e\x80-\xff]*$',
                    ).hasMatch(line),
              )) {
        throw const ProxySettingsException('protocol');
      }
      final status = int.parse(match[1]!);
      if (status == 407) throw const ProxySettingsException('authentication');
      if (status < 200 || status >= 300) {
        throw const ProxySettingsException('proxy');
      }
      return;
    }
  }
  throw const ProxySettingsException('protocol');
}

Future<void> _socks(_Channel channel, Uri uri, ProxySettings settings) async {
  final authenticated = settings.username.isNotEmpty;
  await channel.write([5, 1, authenticated ? 2 : 0]);
  final method = await channel.read(2);
  if (method[0] != 5) throw const ProxySettingsException('protocol');
  if (method[1] != (authenticated ? 2 : 0)) {
    throw const ProxySettingsException('authentication');
  }
  if (authenticated) {
    final user = utf8.encode(settings.username);
    final password = utf8.encode(settings.password);
    await channel.write([
      1,
      user.length,
      ...user,
      password.length,
      ...password,
    ]);
    final reply = await channel.read(2);
    if (reply[0] != 1) throw const ProxySettingsException('protocol');
    if (reply[1] != 0) throw const ProxySettingsException('authentication');
  }
  final ip = InternetAddress.tryParse(uri.host);
  final List<int> address;
  if (ip != null) {
    address = [ip.type == InternetAddressType.IPv4 ? 1 : 4, ...ip.rawAddress];
  } else {
    final domain = utf8.encode(uri.host);
    if (domain.isEmpty || domain.length > 255) {
      throw const ProxySettingsException('protocol');
    }
    address = [3, domain.length, ...domain];
  }
  await channel.write([5, 1, 0, ...address, uri.port >> 8, uri.port & 255]);
  final reply = await channel.read(4);
  if (reply[0] != 5 || reply[2] != 0) {
    throw const ProxySettingsException('protocol');
  }
  if (reply[1] != 0) throw const ProxySettingsException('proxy');
  final int length;
  switch (reply[3]) {
    case 1:
      length = 4;
    case 4:
      length = 16;
    case 3:
      length = (await channel.read(1))[0];
      if (length == 0) throw const ProxySettingsException('protocol');
    default:
      throw const ProxySettingsException('protocol');
  }
  await channel.read(length + 2);
}

/// One subscription across handshake reads/writes. Reads never over-consume.
class _Channel {
  _Channel(this.raw) {
    raw.readEventsEnabled = false;
    raw.writeEventsEnabled = false;
    subscription = raw.listen(_event, onError: _error, onDone: _closed);
  }
  final RawSocket raw;
  late final StreamSubscription<RawSocketEvent> subscription;
  Completer<void>? _readable, _writable;
  Object? _failure;
  void Function()? onReadable, onClosed;
  bool ended = false;

  void _event(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      raw.readEventsEnabled = false;
      final ready = _readable;
      _readable = null;
      ready?.complete();
      onReadable?.call();
    } else if (event == RawSocketEvent.write) {
      final ready = _writable;
      _writable = null;
      ready?.complete();
    } else if (event == RawSocketEvent.readClosed ||
        event == RawSocketEvent.closed) {
      _closed();
    }
  }

  void _error(Object error) {
    _failure = const ProxySettingsException('connection');
    _closed();
  }

  void _closed() {
    if (ended) return;
    ended = true;
    final read = _readable, write = _writable;
    _readable = _writable = null;
    read?.complete();
    write?.complete();
    onClosed?.call();
  }

  Future<Uint8List> read(int count) async {
    Uint8List? bytes;
    var offset = 0;
    while (offset < count) {
      final data = raw.read(count - offset);
      if (data != null && data.isNotEmpty) {
        if (offset == 0 && data.length == count) return data;
        bytes ??= Uint8List(count);
        bytes.setRange(offset, offset + data.length, data);
        offset += data.length;
      } else {
        if (ended) throw _failure ?? const ProxySettingsException('protocol');
        final readable = _readable = Completer<void>();
        raw.readEventsEnabled = true;
        await readable.future;
      }
    }
    return bytes ?? Uint8List(0);
  }

  Future<void> write(List<int> bytes) async {
    var offset = 0;
    while (offset < bytes.length) {
      if (ended) throw _failure ?? const ProxySettingsException('connection');
      final written = raw.write(bytes, offset, bytes.length - offset);
      offset += written;
      if (offset < bytes.length) {
        final writable = _writable = Completer<void>();
        raw.writeEventsEnabled = true;
        await writable.future;
      }
    }
  }

  StreamSubscription<RawSocketEvent> detach() {
    raw.readEventsEnabled = false;
    raw.writeEventsEnabled = false;
    return subscription;
  }
}

class _SocketConsumer implements StreamConsumer<List<int>> {
  _SocketConsumer(this.channel);
  final _Channel channel;
  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await for (final data in stream) {
      await channel.write(data);
    }
  }

  @override
  Future<void> close() async => channel.raw.shutdown(SocketDirection.send);
}

/// HttpClient's factory expects a Socket, but its factory path does not perform
/// TLS upgrades. TLS has already been negotiated above with normal trust checks.
class _TransportSocket extends Stream<Uint8List> implements Socket {
  _TransportSocket(this.channel, this.onClosed) {
    _sink = IOSink(_SocketConsumer(channel));
    // Consumers normally observe stream errors; avoid an unhandled sink.done
    // error when a cancelled request stops writing before the socket fails.
    unawaited(_sink.done.then<void>((_) {}, onError: (Object _) {}));
    _stream = StreamController<Uint8List>(
      onListen: _resume,
      onPause: () => channel.raw.readEventsEnabled = false,
      onResume: _resume,
      onCancel: destroy,
    );
    channel.onReadable = _drain;
    channel.onClosed = () {
      _drain();
      _stream.close();
      onClosed();
    };
  }
  final _Channel channel;
  final void Function() onClosed;
  late final IOSink _sink;
  late final StreamController<Uint8List> _stream;
  bool _destroyed = false;
  void _resume() {
    if (!_destroyed) _drain();
  }

  void _drain() {
    if (_destroyed || _stream.isPaused || !_stream.hasListener) return;
    var available = channel.raw.available();
    while (available > 0) {
      final data = channel.raw.read(available);
      if (data == null) break;
      _stream.add(data);
      if (_stream.isPaused) return;
      available = channel.raw.available();
    }
    if (!channel.ended) channel.raw.readEventsEnabled = true;
  }

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _stream.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );
  @override
  void destroy() {
    if (_destroyed) return;
    _destroyed = true;
    channel.raw.close();
    _stream.close();
    onClosed();
  }

  @override
  InternetAddress get address => channel.raw.address;
  @override
  InternetAddress get remoteAddress => channel.raw.remoteAddress;
  @override
  int get port => channel.raw.port;
  @override
  int get remotePort => channel.raw.remotePort;
  @override
  bool setOption(SocketOption option, bool enabled) =>
      channel.raw.setOption(option, enabled);
  @override
  Uint8List getRawOption(RawSocketOption option) =>
      channel.raw.getRawOption(option);
  @override
  void setRawOption(RawSocketOption option) => channel.raw.setRawOption(option);
  @override
  Encoding get encoding => _sink.encoding;
  @override
  set encoding(Encoding value) => _sink.encoding = value;
  @override
  void add(List<int> data) => _sink.add(data);
  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _sink.addError(error, stackTrace);
  @override
  Future<void> addStream(Stream<List<int>> stream) => _sink.addStream(stream);
  @override
  void write(Object? object) => _sink.write(object);
  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      _sink.writeAll(objects, separator);
  @override
  void writeln([Object? object = '']) => _sink.writeln(object);
  @override
  void writeCharCode(int charCode) => _sink.writeCharCode(charCode);
  @override
  Future<void> flush() => _sink.flush();
  @override
  Future<void> close() => _sink.close();
  @override
  Future<void> get done => _sink.done;
  // Socket's private SDK-only detach method is intentionally unsupported:
  // this adapter is already the terminal socket returned to HttpClient.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SecureTransportSocket extends _TransportSocket implements SecureSocket {
  _SecureTransportSocket(super.channel, super.onClosed);
  RawSecureSocket get _secure => channel.raw as RawSecureSocket;
  @override
  X509Certificate? get peerCertificate => _secure.peerCertificate;
  @override
  String? get selectedProtocol => _secure.selectedProtocol;
  @override
  void renegotiate({
    bool useSessionCache = true,
    bool requestClientCertificate = false,
    bool requireClientCertificate = false,
  }) => throw UnsupportedError('TLS renegotiation is not supported');
}
