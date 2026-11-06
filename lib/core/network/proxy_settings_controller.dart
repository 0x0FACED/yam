import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'proxy_settings.dart';
import 'proxy_transport.dart';

abstract class ProxySettingsStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class PlatformProxySettingsStorage implements ProxySettingsStorage {
  const PlatformProxySettingsStorage();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: false,
      storageNamespace: 'yam_network_proxy',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
    mOptions: MacOsOptions(
      usesDataProtectionKeychain: false,
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );
  static const _key = 'yam.network.proxy.v1';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

class ProxySettingsController extends ChangeNotifier {
  ProxySettingsController({
    ProxySettingsStorage? storage,
    SecurityContext? securityContext,
    Duration handshakeTimeout = const Duration(seconds: 20),
  }) : _storage = storage ?? const PlatformProxySettingsStorage(),
       _transport = ProxyTransport(
         securityContext: securityContext,
         handshakeTimeout: handshakeTimeout,
       );

  final ProxySettingsStorage _storage;
  final ProxyTransport _transport;
  ProxySettings _settings = const ProxySettings();
  bool _initialized = false, _saving = false, _disposed = false;
  String? _failureCode;
  Future<void> _operations = Future<void>.value();
  Future<void>? _initializing;

  ProxySettings get settings => _settings;
  bool get initialized => _initialized;
  bool get saving => _saving;
  String? get failureCode => _failureCode;

  void _ensureAlive() {
    if (_disposed) throw const ProxySettingsException('cancelled');
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _serialize(Future<void> Function() operation) {
    final result = _operations.then((_) async {
      _ensureAlive();
      await operation();
    });
    _operations = result.catchError((Object _) {});
    return result;
  }

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??= _serialize(() async {
      if (_initialized) return;
      try {
        final raw = await _storage.read();
        _ensureAlive();
        final loaded = raw == null
            ? const ProxySettings()
            : ProxySettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        _settings = loaded;
        _initialized = true;
        _failureCode = null;
      } catch (_) {
        _ensureAlive();
        _failureCode = 'storage';
        throw const ProxySettingsException('storage');
      } finally {
        _notify();
      }
    }).whenComplete(() => _initializing = null);
  }

  Future<void> save(ProxySettings value) => _serialize(() async {
    value.validate();
    _saving = true;
    _failureCode = null;
    _notify();
    try {
      try {
        await _storage.write(jsonEncode(value.toJson()));
      } catch (_) {
        throw const ProxySettingsException('storage');
      }
      _ensureAlive();
      // Persist first. A write failure retains the previous active route.
      // Explicit saves also recover from unreadable stored state.
      _settings = value;
      _initialized = true;
      await _transport.closeRoutes();
    } on ProxySettingsException catch (failure) {
      _failureCode = failure.code;
      rethrow;
    } finally {
      _saving = false;
      _notify();
    }
  });

  HttpClient createHttpClient() {
    _ensureAlive();
    return HttpClient()
      // Ignore environment proxies: the explicit app setting is authoritative.
      ..findProxy = ((_) => 'DIRECT')
      ..connectionFactory = (uri, _, _) async => _connectWhenInitialized(uri);
  }

  ConnectionTask<Socket> _connectWhenInitialized(Uri uri) {
    final result = Completer<Socket>();
    ConnectionTask<Socket>? active;
    var cancelled = false;
    void cancel() {
      cancelled = true;
      active?.cancel();
      if (!result.isCompleted) {
        result.completeError(const ProxySettingsException('cancelled'));
      }
    }

    // HttpClient must receive its cancellable task before storage I/O starts.
    unawaited(() async {
      try {
        await initialize();
        _ensureAlive();
        if (cancelled) return;
        final task = await _transport.connect(uri, _settings);
        active = task;
        if (cancelled) task.cancel();
        final socket = await task.socket;
        if (cancelled || _disposed) {
          socket.destroy();
          throw const ProxySettingsException('cancelled');
        }
        if (!result.isCompleted) result.complete(socket);
      } catch (error, stackTrace) {
        if (!result.isCompleted) result.completeError(error, stackTrace);
      }
    }());
    return ConnectionTask.fromSocket(result.future, cancel);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_transport.closeRoutes());
    super.dispose();
  }
}
