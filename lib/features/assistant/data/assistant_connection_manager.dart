import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/features/assistant/data/chatgpt_oauth.dart';
import 'package:yam/features/assistant/data/openai_transport.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';

abstract class AssistantCredentialStorage {
  Future<String?> read();
  Future<void> write(String value);
}

class PlatformAssistantCredentialStorage implements AssistantCredentialStorage {
  const PlatformAssistantCredentialStorage();
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
    mOptions: MacOsOptions(
      usesDataProtectionKeychain: false,
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );
  static const _key = 'yam.assistant.credentials.v1';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

class AssistantConnectionManager extends ChangeNotifier {
  AssistantConnectionManager({
    AssistantCredentialStorage? storage,
    HttpClient Function()? httpClientFactory,
    Uri? apiBase,
    Uri? oauthIssuer,
    Future<bool> Function(Uri)? openBrowser,
    DateTime Function()? now,
  }) : _storage = storage ?? const PlatformAssistantCredentialStorage(),
       _httpClientFactory = httpClientFactory ?? HttpClient.new,
       _apiBase = apiBase ?? Uri.parse('https://api.openai.com/v1/'),
       _now = now ?? DateTime.now {
    _oauth = ChatGptOAuth(
      httpClient: _httpClientFactory(),
      issuer: oauthIssuer,
      openBrowser: openBrowser,
      now: _now,
    );
    _gateway = OpenAiGateway(
      bearer: _bearer,
      apiBase: _apiBase,
      httpClientFactory: _httpClientFactory,
      useNamespaces: () => _mode == AssistantConnectionMode.chatgpt,
    );
  }

  final AssistantCredentialStorage _storage;
  final HttpClient Function() _httpClientFactory;
  final Uri _apiBase;
  final DateTime Function() _now;
  late final ChatGptOAuth _oauth;
  late final OpenAiGateway _gateway;
  final Map<String, ChatGptRegistration> _registrations = {};
  final Map<String, String> _modelChoices = {};
  final Set<String> _welcomed = {};
  final Set<HttpClient> _transcriptionClients = {};
  String? _activeClientId, _hostId, _apiKey, _failureCode;
  AssistantConnectionMode _mode = AssistantConnectionMode.apiKey;
  List<AssistantModel> _models = const [];
  bool _loading = false, _disposed = false, _initialized = false;
  Future<void>? _initializing;
  final Map<String, Future<ChatGptRegistration>> _refreshing = {};
  int _credentialGeneration = 0;
  Future<void> _operations = Future<void>.value();
  Future<void> _writes = Future<void>.value();

  bool get isLoading => _loading;
  bool get isConnected => _mode == AssistantConnectionMode.apiKey
      ? hasApiKey
      : _registration?.hasSession == true;
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;
  AssistantConnectionMode get mode => _mode;
  String? get accountLabel =>
      _mode == AssistantConnectionMode.chatgpt ? _registration?.label : null;
  String? get activeChatGptClientId => _activeClientId;
  String? get model => _modelChoices[_choiceKey];
  String? get failureCode => _failureCode;
  List<AssistantModel> get models => List.unmodifiable(_models);
  AssistantGateway get gateway => _gateway;
  bool get needsPlanWelcome =>
      _mode == AssistantConnectionMode.chatgpt &&
      isConnected &&
      !_welcomed.contains(_activeClientId);
  List<ChatGptRegistrationLabel> get savedChatGptAccounts => _registrations
      .values
      .where((value) => value.subject != null)
      .map(
        (value) => ChatGptRegistrationLabel(
          clientId: value.clientId,
          label: value.label,
        ),
      )
      .toList(growable: false);
  ChatGptRegistration? get _registration => _registrations[_activeClientId];
  String get _choiceKey => _mode == AssistantConnectionMode.apiKey
      ? 'apiKey'
      : 'chatgpt:$_activeClientId';

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _ensureAlive() {
    if (_disposed) throw const AssistantFailure('cancelled');
  }

  Future<void> _save() async {
    _ensureAlive();
    try {
      final snapshot = jsonEncode({
        'host_id': _hostId,
        'api_key': _apiKey,
        'mode': _mode.name,
        'active_client_id': _activeClientId,
        'registrations': _registrations.values
            .map((value) => value.toJson())
            .toList(),
        'models': _modelChoices,
        'welcomed': _welcomed.toList(),
      });
      final write = _writes.then((_) => _storage.write(snapshot));
      _writes = write.catchError((Object _) {});
      await write;
    } catch (_) {
      throw const AssistantFailure('storage');
    }
  }

  Future<void> _run(Future<void> Function() operation) {
    final result = _operations.then((_) async {
      _ensureAlive();
      _loading = true;
      _failureCode = null;
      _notify();
      try {
        await operation();
      } on AssistantFailure catch (failure) {
        _failureCode = failure.code;
        rethrow;
      } catch (_) {
        _failureCode = 'protocol';
        throw const AssistantFailure('protocol');
      } finally {
        _loading = false;
        _notify();
      }
    });
    _operations = result.catchError((Object _) {});
    return result;
  }

  Future<void> initialize() {
    if (_initialized) return Future<void>.value();
    return _initializing ??=
        _run(() async {
          String? raw;
          try {
            raw = await _storage.read();
          } catch (_) {
            throw const AssistantFailure('storage');
          }
          if (raw != null) {
            try {
              final json = jsonDecode(raw) as Map<String, dynamic>;
              _hostId = json['host_id'] as String?;
              _apiKey = json['api_key'] as String?;
              _mode = json['mode'] == 'chatgpt'
                  ? AssistantConnectionMode.chatgpt
                  : AssistantConnectionMode.apiKey;
              _activeClientId = json['active_client_id'] as String?;
              for (final row in (json['registrations'] as List? ?? [])) {
                final registration = ChatGptRegistration.fromJson(
                  Map<String, dynamic>.from(row as Map),
                );
                if (registration.clientId != 'dynamic_agent_client') {
                  _registrations[registration.clientId] = registration;
                }
              }
              _modelChoices.addAll(
                (json['models'] as Map? ?? {}).cast<String, String>(),
              );
              _welcomed.addAll(
                (json['welcomed'] as List? ?? []).cast<String>(),
              );
            } catch (_) {
              throw const AssistantFailure('storage');
            }
          }
          _hostId ??= 'urn:uuid:${const Uuid().v4()}';
          await _save();
          _initialized = true;
          if (isConnected) await _loadModels();
        }).whenComplete(() {
          _initializing = null;
        });
  }

  Future<void> _loadModels() async {
    _models = const [];
    if (!isConnected) return;
    _models = await _gateway.listModels();
    if (!_models.any((value) => value.id == model)) {
      _modelChoices[_choiceKey] = _models.first.id;
    }
    await _save();
  }

  Future<void> connectApiKey(String value) => _run(() async {
    final key = value.trim();
    if (key.isEmpty || key.contains(RegExp(r'\s'))) {
      throw const AssistantFailure('auth');
    }
    final candidate = OpenAiGateway(
      bearer: () async => key,
      apiBase: _apiBase,
      httpClientFactory: _httpClientFactory,
    );
    List<AssistantModel> available;
    try {
      available = await candidate.listModels();
    } finally {
      candidate.close();
    }
    _ensureAlive();
    _gateway.cancel();
    _credentialGeneration++;
    _apiKey = key;
    _mode = AssistantConnectionMode.apiKey;
    _models = available;
    if (!_models.any((value) => value.id == model)) {
      _modelChoices[_choiceKey] = _models.first.id;
    }
    await _save();
  });

  Future<void> signInChatGpt() => _signIn(_registration);

  /// Adds a separate registration without replacing the selected account on failure.
  Future<void> addChatGptAccount() => _signIn(null);

  Future<void> _signIn(ChatGptRegistration? selected) => _run(() async {
    _hostId ??= 'urn:uuid:${const Uuid().v4()}';
    await _save();
    final authenticated = await _oauth.authorize(
      hostId: _hostId!,
      registration: selected,
      onIssuedClient: (clientId) async {
        _ensureAlive();
        // Registration survives an invalid_grant but is never active or labeled
        // as a verified account until the signed identity has been checked.
        _registrations.putIfAbsent(
          clientId,
          () => ChatGptRegistration(clientId: clientId),
        );
        if (selected == null && _activeClientId == null) {
          _activeClientId = clientId;
        }
        await _save();
      },
    );
    _ensureAlive();
    _gateway.cancel();
    _credentialGeneration++;
    _registrations[authenticated.clientId] = authenticated;
    _activeClientId = authenticated.clientId;
    _mode = AssistantConnectionMode.chatgpt;
    _models = const [];
    await _save();
    await _loadModels();
  });

  void cancelSignIn() => _oauth.cancel();

  Future<void> selectChatGptAccount(String clientId) => _run(() async {
    if (!_registrations.containsKey(clientId)) {
      throw const AssistantFailure('auth');
    }
    _gateway.cancel();
    _credentialGeneration++;
    _activeClientId = clientId;
    _mode = AssistantConnectionMode.chatgpt;
    await _save();
    await _loadModels();
  });

  Future<void> selectMode(AssistantConnectionMode value) => _run(() async {
    _gateway.cancel();
    _credentialGeneration++;
    _mode = value;
    await _save();
    await _loadModels();
  });

  Future<void> selectModel(String value) => _run(() async {
    if (!_models.any((candidate) => candidate.id == value)) {
      throw const AssistantFailure('no_models');
    }
    _modelChoices[_choiceKey] = value;
    await _save();
  });

  Future<void> acknowledgePlanWelcome() => _run(() async {
    if (_registration?.hasSession != true || _activeClientId == null) return;
    _welcomed.add(_activeClientId!);
    await _save();
  });

  Future<String> _bearer() async {
    _ensureAlive();
    if (_mode == AssistantConnectionMode.apiKey) {
      if (!hasApiKey) throw const AssistantFailure('auth');
      return _apiKey!;
    }
    final registration = _registration;
    if (registration == null || !registration.hasSession) {
      throw const AssistantFailure('auth');
    }
    final expiresAt = registration.expiresAt;
    if (expiresAt == null) throw const AssistantFailure('auth');
    final now = _now();
    if (expiresAt.isAfter(now.add(const Duration(minutes: 2))) ||
        (registration.earliestRefreshAt?.isAfter(now) == true &&
            expiresAt.isAfter(now))) {
      return registration.accessToken!;
    }
    final generation = _credentialGeneration;
    final pending = _refreshing.putIfAbsent(
      registration.clientId,
      () => _refresh(registration),
    );
    try {
      final refreshed = await pending;
      if (generation != _credentialGeneration ||
          refreshed.clientId != registration.clientId) {
        throw const AssistantFailure('cancelled');
      }
      return refreshed.accessToken!;
    } finally {
      if (identical(_refreshing[registration.clientId], pending)) {
        _refreshing.remove(registration.clientId);
      }
    }
  }

  Future<ChatGptRegistration> _refresh(ChatGptRegistration previous) async {
    ChatGptRegistration updated;
    try {
      updated = await _oauth.refresh(previous);
    } on AssistantFailure catch (failure) {
      if (!_disposed &&
          identical(_registrations[previous.clientId], previous) &&
          (failure.code == 'auth' || failure.code == 'permission')) {
        _registrations[previous.clientId] = previous.withoutTokens();
        await _save();
        _failureCode = failure.code;
        _notify();
      }
      rethrow;
    }
    _ensureAlive();
    if (!identical(_registrations[previous.clientId], previous)) {
      throw const AssistantFailure('cancelled');
    }
    _registrations[updated.clientId] = updated;
    await _save();
    _notify();
    return updated;
  }

  Future<void> disconnect() {
    _gateway.cancel();
    _oauth.cancel();
    return _run(() async {
      // Let a rotating refresh finish so revocation uses the latest token.
      try {
        await _refreshing[_activeClientId];
      } on AssistantFailure catch (_) {
        /* Clear locally below. */
      }
      _credentialGeneration++;
      var unconfirmed = false;
      if (_mode == AssistantConnectionMode.apiKey) {
        _apiKey = null;
      } else {
        final registration = _registration;
        if (registration != null) {
          try {
            await _oauth.revoke(registration);
          } on AssistantFailure catch (_) {
            unconfirmed = true;
          }
          _registrations[registration.clientId] = registration.withoutTokens();
        }
      }
      _models = const [];
      await _save();
      if (unconfirmed) throw const AssistantFailure('revocation_unconfirmed');
    });
  }

  Future<String> transcribe(
    Uint8List bytes, {
    required String filename,
    required String mimeType,
  }) async {
    _ensureAlive();
    final key = _apiKey;
    if (key == null || key.isEmpty) throw const AssistantFailure('no_api_key');
    if (bytes.isEmpty ||
        bytes.length > 25 * 1024 * 1024 ||
        !RegExp(r'^[A-Za-z0-9_.-]+$').hasMatch(filename) ||
        !RegExp(r'^(audio|video)/[A-Za-z0-9.+-]+$').hasMatch(mimeType)) {
      throw const AssistantFailure('protocol');
    }
    final client = _httpClientFactory();
    _transcriptionClients.add(client);
    try {
      final boundary = 'yam-${const Uuid().v4()}';
      final request = await client
          .postUrl(_apiBase.resolve('audio/transcriptions'))
          .timeout(const Duration(seconds: 30));
      request.followRedirects = false;
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $key');
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );
      request.add(
        utf8.encode(
          '--$boundary\r\nContent-Disposition: form-data; name="model"\r\n\r\ngpt-transcribe\r\n'
          '--$boundary\r\nContent-Disposition: form-data; name="file"; filename="$filename"\r\n'
          'Content-Type: $mimeType\r\n\r\n',
        ),
      );
      request.add(bytes);
      request.add(utf8.encode('\r\n--$boundary--\r\n'));
      final dynamic response = await readAssistantJson(
        await request.close().timeout(const Duration(minutes: 2)),
      );
      if (response is! Map || response['text'] is! String) {
        throw const AssistantFailure('protocol');
      }
      return response['text'] as String;
    } on AssistantFailure {
      rethrow;
    } on TimeoutException {
      throw const AssistantFailure('network');
    } on IOException {
      throw const AssistantFailure('network');
    } finally {
      _transcriptionClients.remove(client);
      client.close(force: true);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _credentialGeneration++;
    _gateway.close();
    _oauth.close();
    for (final client in _transcriptionClients) {
      client.close(force: true);
    }
    _transcriptionClients.clear();
    super.dispose();
  }
}

/// Safe display metadata only; never exposes credentials to UI consumers.
class ChatGptRegistrationLabel {
  const ChatGptRegistrationLabel({required this.clientId, required this.label});
  final String clientId, label;
}
