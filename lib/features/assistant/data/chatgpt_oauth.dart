import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:crypto/crypto.dart';
import 'package:jose/jose.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yam/features/assistant/data/openai_transport.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/l10n/generated/app_localizations.dart';

class ChatGptRegistration {
  ChatGptRegistration({
    required this.clientId,
    this.subject,
    this.email,
    this.idToken,
    this.accessToken,
    this.refreshToken,
    this.expiresAt,
    this.earliestRefreshAt,
    this.scopes = const [],
  });

  factory ChatGptRegistration.fromJson(Map<String, dynamic> json) =>
      ChatGptRegistration(
        clientId: json['client_id'] as String,
        subject: json['subject'] as String?,
        email: json['email'] as String?,
        idToken: json['id_token'] as String?,
        accessToken: json['access_token'] as String?,
        refreshToken: json['refresh_token'] as String?,
        expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
        earliestRefreshAt: DateTime.tryParse(
          json['earliest_refresh_at'] as String? ?? '',
        ),
        scopes: (json['scopes'] as List? ?? []).cast<String>(),
      );

  final String clientId;
  final String? subject, email, idToken, accessToken, refreshToken;
  final DateTime? expiresAt, earliestRefreshAt;
  final List<String> scopes;
  bool get hasSession =>
      accessToken != null &&
      refreshToken != null &&
      scopes.contains('chatgpt.tokens.use.direct') &&
      subject != null;
  String get label => '${email ?? subject ?? 'ChatGPT'} · $clientId';
  ChatGptRegistration withoutTokens() =>
      ChatGptRegistration(clientId: clientId, subject: subject, email: email);
  Map<String, dynamic> toJson() => {
    'client_id': clientId,
    'subject': subject,
    'email': email,
    'id_token': idToken,
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt?.toUtc().toIso8601String(),
    'earliest_refresh_at': earliestRefreshAt?.toUtc().toIso8601String(),
    'scopes': scopes,
  };
}

/// Official public-client SIWC protocol. An injected issuer/browser/client allows
/// local HTTP behavioral fixtures without accepting unsigned identity tokens.
class ChatGptOAuth {
  ChatGptOAuth({
    HttpClient? httpClient,
    Uri? issuer,
    Future<bool> Function(Uri)? openBrowser,
    DateTime Function()? now,
  }) : _http = httpClient ?? HttpClient(),
       issuer = issuer ?? Uri.parse('https://auth.openai.com'),
       _openBrowser = openBrowser ?? _systemBrowser,
       _now = now ?? DateTime.now;

  final HttpClient _http;
  final Uri issuer;
  final Future<bool> Function(Uri) _openBrowser;
  final DateTime Function() _now;
  static Future<bool> _systemBrowser(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
  static const resource = 'https://api.openai.com/v1';
  HttpServer? _listener;
  Completer<Map<String, String>>? _callback;
  int _attempt = 0;
  Map<String, dynamic>? _discovery;

  Uri _endpoint(String path) => issuer.resolve(path);
  String _random() {
    final random = Random.secure();
    return base64Url
        .encode(List<int>.generate(32, (_) => random.nextInt(256)))
        .replaceAll('=', '');
  }

  Future<dynamic> _json(
    String method,
    Uri uri, {
    Map<String, String>? form,
  }) async {
    try {
      final request = await _http
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 30));
      request.followRedirects = false;
      if (form != null) {
        request.headers.contentType = ContentType(
          'application',
          'x-www-form-urlencoded',
        );
        request.write(Uri(queryParameters: form).query);
      }
      return await readAssistantJson(
        await request.close().timeout(const Duration(seconds: 30)),
      );
    } on AssistantFailure {
      rethrow;
    } on IOException {
      throw const AssistantFailure('network');
    } on TimeoutException {
      throw const AssistantFailure('network');
    }
  }

  Future<Map<String, dynamic>> _configuration() async {
    if (_discovery != null) return _discovery!;
    final dynamic config = await _json(
      'GET',
      _endpoint('/.well-known/openid-configuration'),
    );
    if (config is! Map<String, dynamic> ||
        config['issuer'] != issuer.toString()) {
      throw const AssistantFailure('auth');
    }
    for (final name in ['jwks_uri', 'revocation_endpoint']) {
      final endpoint = Uri.tryParse(config[name] as String? ?? '');
      if (endpoint == null ||
          endpoint.origin != issuer.origin ||
          endpoint.userInfo.isNotEmpty ||
          endpoint.fragment.isNotEmpty) {
        throw const AssistantFailure('auth');
      }
    }
    return _discovery = config;
  }

  Future<Map<String, dynamic>> validateIdToken(
    String token,
    String clientId, {
    String? nonce,
    String? subject,
  }) async {
    try {
      final configuration = await _configuration();
      final dynamic jwks = await _json(
        'GET',
        Uri.parse(configuration['jwks_uri'] as String),
      );
      if (jwks is! Map || jwks['keys'] is! List) {
        throw const AssistantFailure('auth');
      }
      final store = JsonWebKeyStore();
      for (final key in (jwks['keys'] as List).whereType<Map>()) {
        if (key['kty'] == 'RSA' &&
            (key['use'] == null || key['use'] == 'sig') &&
            (key['alg'] == null || key['alg'] == 'RS256')) {
          store.addKey(JsonWebKey.fromJson(Map<String, dynamic>.from(key)));
        }
      }
      final signed = JsonWebSignature.fromCompactSerialization(token);
      final payload = await signed.getPayload(
        store,
        allowedAlgorithms: ['RS256'],
      );
      final dynamic claims = jsonDecode(utf8.decode(payload.data));
      if (claims is! Map<String, dynamic>) throw const AssistantFailure('auth');
      final audience = claims['aud'];
      final validAudience =
          audience == clientId ||
          (audience is List && audience.contains(clientId));
      final now = _now().millisecondsSinceEpoch ~/ 1000;
      if (claims['iss'] != issuer.toString() ||
          !validAudience ||
          (audience is List &&
              audience.length > 1 &&
              claims['azp'] != clientId) ||
          (claims['azp'] != null && claims['azp'] != clientId) ||
          claims['exp'] is! num ||
          (claims['exp'] as num) <= now ||
          (claims['nbf'] is num && (claims['nbf'] as num) > now) ||
          claims['sub'] is! String ||
          (claims['sub'] as String).isEmpty ||
          (nonce != null && claims['nonce'] != nonce) ||
          (subject != null && claims['sub'] != subject) ||
          (claims['email'] != null && claims['email_verified'] != true)) {
        throw const AssistantFailure('auth');
      }
      return claims;
    } on AssistantFailure {
      rethrow;
    } catch (_) {
      throw const AssistantFailure('auth');
    }
  }

  Future<ChatGptRegistration> authorize({
    required String hostId,
    ChatGptRegistration? registration,
    required Future<void> Function(String clientId) onIssuedClient,
  }) async {
    cancel();
    final attempt = _attempt;
    final state = _random();
    final nonce = _random();
    final verifier = _random();
    final challenge = base64Url
        .encode(sha256.convert(ascii.encode(verifier)).bytes)
        .replaceAll('=', '');
    final callback = Completer<Map<String, String>>();
    _callback = callback;
    final result = callback.future;
    unawaited(result.then<void>((_) {}, onError: (Object _, StackTrace _) {}));
    final listener = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    if (attempt != _attempt) {
      await listener.close(force: true);
      throw const AssistantFailure('cancelled');
    }
    _listener = listener;
    final redirect = Uri.parse(
      'http://127.0.0.1:${listener.port}/auth/callback',
    );
    listener.listen(
      (request) async {
        if (request.method != 'GET' || request.uri.path != '/auth/callback') {
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
          return;
        }
        final params = request.uri.queryParameters;
        final duplicates = request.uri.queryParametersAll.values.any(
          (values) => values.length != 1,
        );
        if (!callback.isCompleted) {
          if (duplicates || params['state'] != state) {
            callback.completeError(const AssistantFailure('auth'));
          } else {
            callback.complete(params);
          }
        }
        request.response.headers.contentType = ContentType(
          'text',
          'plain',
          charset: 'utf-8',
        );
        final language = PlatformDispatcher.instance.locale.languageCode;
        request.response.write(
          lookupAppLocalizations(
            Locale(language == 'ru' ? 'ru' : 'en'),
          ).assistantOAuthReturn,
        );
        await request.response.close();
      },
      onError: (Object _) {
        if (!callback.isCompleted) {
          callback.completeError(const AssistantFailure('network'));
        }
      },
    );
    try {
      final uri = _endpoint('/api/accounts/authorize').replace(
        queryParameters: {
          'client_id': registration?.clientId ?? 'dynamic_agent_client',
          if (registration == null) 'agent_name_hint': 'YAM',
          'ext_agent_host_id': hostId,
          if (registration?.idToken != null)
            'id_token_hint': registration!.idToken!,
          if (registration?.email != null) 'login_hint': registration!.email!,
          'response_type': 'code',
          'redirect_uri': redirect.toString(),
          'scope':
              'openid profile email offline_access resource.invoke chatgpt.tokens.use.direct',
          'resource': resource,
          'state': state,
          'nonce': nonce,
          'code_challenge_method': 'S256',
          'code_challenge': challenge,
        },
      );
      // Attach a listener before opening the browser: callback may return before
      // the browser-launch future, including in native integration fixtures.
      final opened = _openBrowser(uri);
      final params =
          await Future.wait<dynamic>([
                result,
                opened.then((ok) {
                  if (!ok) throw const AssistantFailure('network');
                }),
              ], eagerError: true)
              .timeout(const Duration(minutes: 5))
              .then((values) => values.first as Map<String, String>);
      if (attempt != _attempt) throw const AssistantFailure('cancelled');
      if (params['error'] != null) {
        throw AssistantFailure(
          params['error'] == 'access_denied' ? 'permission' : 'auth',
        );
      }
      final issued = params['client_id'] ?? registration?.clientId;
      if (issued == null ||
          issued.isEmpty ||
          issued == 'dynamic_agent_client' ||
          (registration != null && issued != registration.clientId) ||
          params['code'] == null ||
          params['code']!.isEmpty) {
        throw const AssistantFailure('auth');
      }
      await onIssuedClient(issued);
      final dynamic tokens = await _json(
        'POST',
        _endpoint('/api/accounts/oauth/token'),
        form: {
          'grant_type': 'authorization_code',
          'client_id': issued,
          'code': params['code']!,
          'code_verifier': verifier,
          'redirect_uri': redirect.toString(),
          'resource': resource,
        },
      );
      final value = await _tokens(
        tokens,
        issued,
        nonce: nonce,
        previous: registration,
      );
      if (attempt != _attempt) throw const AssistantFailure('cancelled');
      return value;
    } on TimeoutException {
      throw const AssistantFailure('cancelled');
    } on AssistantFailure {
      rethrow;
    } catch (_) {
      throw const AssistantFailure('network');
    } finally {
      if (!callback.isCompleted) {
        callback.completeError(const AssistantFailure('cancelled'));
      }
      await listener.close(force: true);
      if (identical(_listener, listener)) {
        _listener = null;
        _callback = null;
      }
    }
  }

  Future<ChatGptRegistration> _tokens(
    dynamic json,
    String clientId, {
    String? nonce,
    ChatGptRegistration? previous,
  }) async {
    if (json is! Map ||
        json['access_token'] is! String ||
        (json['access_token'] as String).isEmpty ||
        json['refresh_token'] is! String ||
        (json['refresh_token'] as String).isEmpty ||
        json['token_type'] != 'Bearer' ||
        json['expires_in'] is! num ||
        (json['expires_in'] as num) <= 0 ||
        json['id_token'] is! String ||
        json['scope'] is! String) {
      throw const AssistantFailure('auth');
    }
    final claims = await validateIdToken(
      json['id_token'] as String,
      clientId,
      nonce: nonce,
      subject: previous?.subject,
    );
    final scopes = (json['scope'] as String).split(RegExp(r'\s+'));
    if (!scopes.contains('chatgpt.tokens.use.direct') ||
        !scopes.contains('resource.invoke')) {
      throw const AssistantFailure('permission');
    }
    final earliest = json['earliest_refresh_at'];
    return ChatGptRegistration(
      clientId: clientId,
      subject: claims['sub'] as String,
      email: claims['email'] as String?,
      idToken: json['id_token'] as String,
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: _now().add(
        Duration(seconds: (json['expires_in'] as num).toInt()),
      ),
      earliestRefreshAt: earliest is num
          ? DateTime.fromMillisecondsSinceEpoch(
              earliest.toInt() * 1000,
              isUtc: true,
            )
          : earliest is String
          ? DateTime.tryParse(earliest)
          : null,
      scopes: scopes,
    );
  }

  Future<ChatGptRegistration> refresh(ChatGptRegistration previous) async {
    final dynamic tokens = await _json(
      'POST',
      _endpoint('/api/accounts/oauth/token'),
      form: {
        'grant_type': 'refresh_token',
        'client_id': previous.clientId,
        'refresh_token': previous.refreshToken!,
        'resource': resource,
      },
    );
    return _tokens(tokens, previous.clientId, previous: previous);
  }

  Future<void> revoke(ChatGptRegistration registration) async {
    if (registration.refreshToken == null) return;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final configuration = await _configuration();
        await _json(
          'POST',
          Uri.parse(configuration['revocation_endpoint'] as String),
          form: {
            'token': registration.refreshToken!,
            'token_type_hint': 'refresh_token',
            'client_id': registration.clientId,
          },
        );
        return;
      } on AssistantFailure catch (failure) {
        if (failure.code != 'network' || attempt == 2) rethrow;
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (1 << attempt)),
        );
      }
    }
  }

  void cancel() {
    _attempt++;
    final callback = _callback;
    if (callback != null && !callback.isCompleted) {
      callback.completeError(const AssistantFailure('cancelled'));
    }
    _callback = null;
    final listener = _listener;
    _listener = null;
    if (listener != null) unawaited(listener.close(force: true));
  }

  void close() {
    cancel();
    _http.close(force: true);
  }
}
