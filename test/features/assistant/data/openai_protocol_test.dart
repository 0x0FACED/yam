import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jose/jose.dart';
import 'package:yam/features/assistant/data/assistant_connection_manager.dart';
import 'package:yam/features/assistant/data/chatgpt_oauth.dart';
import 'package:yam/features/assistant/data/openai_transport.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';

Matcher failure(String code) =>
    isA<AssistantFailure>().having((value) => value.code, 'code', code);

class MemoryCredentials implements AssistantCredentialStorage {
  String? value;
  int reads = 0;
  @override
  Future<String?> read() async {
    reads++;
    return value;
  }

  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

/// All tokens/keys are generated local fixtures; no cloud credentials or calls.
class OpenAiFixture {
  OpenAiFixture(this.key, this.otherKey);
  final JsonWebKey key, otherKey;
  late HttpServer server;
  late Uri issuer;
  Uri get api => issuer.resolve('/v1/');
  DateTime clock = DateTime.utc(2026, 11, 6);
  String subject = 'fixture-subject';
  String? invalidClaim;
  bool badState = false, deny = false, badSignature = false, failModels = false;
  bool rejectGrant = false, rejectRefresh = false, omitPlanScope = false;
  int refreshes = 0;
  int revocations = 0;
  final authorizations = <Uri>[];
  final exchanges = <Map<String, String>>[];
  final requests = <Map<String, dynamic>>[];
  final bearerHeaders = <String?>[];
  String? transcriptionBearer, multipart;
  bool oauthCatalog = false;
  String stream =
      'data: {"type":"response.completed","response":{"status":"completed","output":[]}}\n\n';
  final streamStarted = Completer<void>();
  final refreshStarted = Completer<void>();
  bool holdStream = false;
  Completer<void>? releaseStream;

  Future<void> start() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    issuer = Uri.parse('http://127.0.0.1:${server.port}');
    server.listen((request) async {
      try {
        await handle(request);
      } on SocketException {
        /* Expected when testing consumer cancellation. */
      } on HttpException {
        /* Expected when testing consumer cancellation. */
      }
    });
  }

  String idToken({String? nonce}) {
    final claims = <String, dynamic>{
      'iss': issuer.toString(),
      'sub': subject,
      'aud': 'oaiapp_fixture',
      'exp': clock.add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'email': 'fixture@example.test',
      'email_verified': true,
      'nonce': ?nonce,
    };
    switch (invalidClaim) {
      case 'issuer':
        claims['iss'] = 'https://attacker.invalid';
      case 'audience':
        claims['aud'] = 'different-client';
      case 'expiry':
        claims['exp'] = 1;
      case 'nonce':
        claims['nonce'] = 'wrong';
      case 'email':
        claims['email_verified'] = false;
    }
    final builder = JsonWebSignatureBuilder()..jsonContent = claims;
    builder.addRecipient(badSignature ? otherKey : key, algorithm: 'RS256');
    return builder.build().toCompactSerialization();
  }

  Future<bool> browser(Uri uri) async {
    authorizations.add(uri);
    final params = uri.queryParameters;
    final callback = Uri.parse(params['redirect_uri']!).replace(
      queryParameters: {
        'state': badState ? 'wrong' : params['state']!,
        if (deny) 'error': 'access_denied' else 'code': 'fixture-code',
        if (params['client_id'] == 'dynamic_agent_client')
          'client_id': 'oaiapp_fixture',
      },
    );
    final client = HttpClient();
    try {
      await (await client.getUrl(
        callback,
      )).close().then((response) => response.drain<void>());
    } finally {
      client.close(force: true);
    }
    return true;
  }

  Future<void> handle(HttpRequest request) async {
    final response = request.response;
    dynamic result;
    switch (request.uri.path) {
      case '/.well-known/openid-configuration':
        result = {
          'issuer': issuer.toString(),
          'jwks_uri': issuer.resolve('/jwks').toString(),
          'revocation_endpoint': issuer.resolve('/revoke').toString(),
        };
      case '/jwks':
        final public = Map<String, dynamic>.from(key.toJson())
          ..removeWhere(
            (name, _) => ['d', 'p', 'q', 'dp', 'dq', 'qi'].contains(name),
          );
        result = {
          'keys': [public],
        };
      case '/api/accounts/oauth/token':
        final form = Uri.splitQueryString(
          await utf8.decoder.bind(request).join(),
        );
        exchanges.add(form);
        if (rejectGrant ||
            (rejectRefresh && form['grant_type'] == 'refresh_token')) {
          response.statusCode = 400;
          result = {
            'error': 'invalid_grant',
            'error_description': 'private provider details',
          };
          break;
        }
        if (form['grant_type'] == 'refresh_token') {
          refreshes++;
          if (!refreshStarted.isCompleted) refreshStarted.complete();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        } else {
          final authorization = authorizations.last.queryParameters;
          expect(form['client_id'], 'oaiapp_fixture');
          expect(form['redirect_uri'], authorization['redirect_uri']);
          final challenge = base64Url
              .encode(
                sha256.convert(ascii.encode(form['code_verifier']!)).bytes,
              )
              .replaceAll('=', '');
          expect(challenge, authorization['code_challenge']);
        }
        result = {
          'access_token': 'fixture-access-$refreshes',
          'refresh_token': 'fixture-refresh-$refreshes',
          'token_type': 'Bearer',
          'expires_in': 3600,
          'scope': omitPlanScope
              ? 'openid profile email'
              : 'openid profile email offline_access resource.invoke chatgpt.tokens.use.direct',
          'id_token': idToken(
            nonce: form['grant_type'] == 'authorization_code'
                ? authorizations.last.queryParameters['nonce']
                : null,
          ),
        };
      case '/revoke':
        final form = Uri.splitQueryString(
          await utf8.decoder.bind(request).join(),
        );
        expect(form['client_id'], 'oaiapp_fixture');
        expect(form['token_type_hint'], 'refresh_token');
        expect(form['token'], 'fixture-refresh-$refreshes');
        revocations++;
        await response.close();
        return;
      case '/v1/models':
        bearerHeaders.add(
          request.headers.value(HttpHeaders.authorizationHeader),
        );
        if (failModels) {
          response.statusCode = 401;
          result = {
            'error': {
              'code': 'invalid_api_key',
              'message': 'secret-body-fixture',
            },
          };
        } else {
          result = oauthCatalog
              ? {
                  'models': [
                    {
                      'slug': 'gpt-fixture',
                      'display_name': 'Fixture',
                      'visibility': 'list',
                    },
                    {'slug': 'gpt-hidden', 'visibility': 'hide'},
                    {'slug': 'gpt-image-fixture', 'visibility': 'list'},
                  ],
                }
              : {
                  'data': [
                    {'id': 'gpt-4o'},
                    {'id': 'gpt-4o-mini-transcribe'},
                    {'id': 'text-embedding-3-small'},
                    {'id': 'dall-e-3'},
                  ],
                };
        }
      case '/v1/responses':
        requests.add(
          jsonDecode(await utf8.decoder.bind(request).join())
              as Map<String, dynamic>,
        );
        response.headers.contentType = ContentType('text', 'event-stream');
        for (final byte in utf8.encode(stream)) {
          response.add([byte]);
        }
        await response.flush();
        if (!streamStarted.isCompleted) streamStarted.complete();
        if (holdStream) await (releaseStream ??= Completer<void>()).future;
        await response.close();
        return;
      case '/v1/audio/transcriptions':
        transcriptionBearer = request.headers.value(
          HttpHeaders.authorizationHeader,
        );
        expect(request.headers.contentType?.mimeType, 'multipart/form-data');
        multipart = await utf8.decoder.bind(request).join();
        result = {'text': 'яблоко'};
      default:
        response.statusCode = 404;
        result = {};
    }
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(result));
    await response.close();
  }

  Future<void> close() async {
    final release = releaseStream;
    if (release != null && !release.isCompleted) release.complete();
    await server.close(force: true);
  }
}

void main() {
  late JsonWebKey signingKey, wrongKey;
  setUpAll(() {
    signingKey = JsonWebKey.generate('RS256', keyBitLength: 2048);
    wrongKey = JsonWebKey.generate('RS256', keyBitLength: 2048);
  });
  late OpenAiFixture fixture;
  setUp(() async {
    fixture = OpenAiFixture(signingKey, wrongKey);
    await fixture.start();
  });
  tearDown(() async {
    await fixture.close();
  });

  test(
    'SSE handles fragmented UTF8, CRLF, multiline data and ignores unterminated data',
    () async {
      final bytes = utf8.encode(
        ': comment\r\ndata: {"text":\r\ndata: "еда"}\r\n\r\ndata: ignored',
      );
      final events = await assistantSseData(
        Stream.fromIterable(bytes.map((byte) => [byte])),
      ).toList();
      expect(events, ['{"text":\n"еда"}']);
    },
  );

  test(
    'both catalog shapes preserve server order and exclude specialized models',
    () async {
      final gateway = OpenAiGateway(
        bearer: () async => 'fixture-key',
        apiBase: fixture.api,
      );
      addTearDown(gateway.close);
      expect((await gateway.listModels()).map((model) => model.id), ['gpt-4o']);
      fixture.oauthCatalog = true;
      final models = await gateway.listModels();
      expect(models.map((model) => model.id), ['gpt-fixture']);
      expect(models.single.label, 'Fixture');
      fixture.failModels = true;
      await expectLater(gateway.listModels(), throwsA(failure('auth')));
    },
  );

  test(
    'API key mode uses plain functions for legacy Responses models',
    () async {
      final manager = AssistantConnectionManager(
        storage: MemoryCredentials(),
        apiBase: fixture.api,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await manager.connectApiKey('fixture-own-key');
      final tools = <Map<String, dynamic>>[
        {'type': 'function', 'name': 'search_food', 'parameters': {}},
      ];
      await manager.gateway.respond(
        model: 'gpt-4o',
        instructions: '',
        input: [],
        tools: tools,
      );
      expect(fixture.requests.single['tools'], tools);
    },
  );

  test(
    'Responses forwards complete image/tool history and returns only terminal output',
    () async {
      final output = [
        {
          'type': 'reasoning',
          'id': 'r1',
          'encrypted_content': 'fixture-encrypted',
          'summary': [],
        },
        {
          'type': 'function_call',
          'namespace': 'yam',
          'name': 'search_food',
          'call_id': 'c1',
          'arguments': '{"query":"яблоко"}',
        },
      ];
      fixture.stream =
          'data: {"type":"response.output_text.delta","delta":"еда"}\n\n'
          'data: ${jsonEncode({
            'type': 'response.completed',
            'response': {'status': 'completed', 'output': output},
          })}\n\n';
      final gateway = OpenAiGateway(
        bearer: () async => 'fixture-key',
        apiBase: fixture.api,
      );
      addTearDown(gateway.close);
      final input = <Map<String, dynamic>>[
        {
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Что это?'},
            {'type': 'input_image', 'image_url': 'data:image/jpeg;base64,AQID'},
          ],
        },
      ];
      final deltas = <String>[];
      final turn = await gateway.respond(
        model: 'gpt-fixture',
        instructions: 'food only',
        input: input,
        tools: [
          {'type': 'function', 'name': 'search_food', 'parameters': {}},
        ],
        onText: deltas.add,
      );
      expect(deltas, ['еда']);
      expect(turn.output, output);
      final request = fixture.requests.single;
      expect(request['input'], input);
      expect(request['store'], false);
      expect(request['stream'], true);
      expect(request['include'], ['reasoning.encrypted_content']);
      expect(request.containsKey('previous_response_id'), false);
      expect((request['tools'] as List).single['name'], 'yam');
      await gateway.respond(
        model: 'gpt-fixture',
        instructions: 'food only',
        input: [
          ...input,
          ...turn.output,
          {'type': 'function_call_output', 'call_id': 'c1', 'output': '[]'},
        ],
        tools: [],
      );
      expect((fixture.requests.last['input'] as List)[1], output.first);
    },
  );

  for (final entry in {
    'data: {"type":"response.output_text.delta","delta":"partial"}\n\n':
        'interrupted',
    'data: {"type":"response.incomplete"}\n\n': 'incomplete',
    'data: {"type":"response.failed","response":{"error":{"code":"subscription_sharing_usage_limit_exceeded","message":"secret"}}}\n\n':
        'usage_limit',
    'data: {"type":"error","code":"subscription_sharing_usage_unavailable","message":"secret"}\n\n':
        'usage_unavailable',
    'data: nope\n\n': 'protocol',
  }.entries) {
    test('never accepts ${entry.value} as completed inference', () async {
      fixture.stream = entry.key;
      final gateway = OpenAiGateway(
        bearer: () async => 'fixture-key',
        apiBase: fixture.api,
      );
      addTearDown(gateway.close);
      await expectLater(
        gateway.respond(
          model: 'gpt-fixture',
          instructions: '',
          input: [],
          tools: [],
        ),
        throwsA(failure(entry.value)),
      );
    });
  }

  test('cancellation interrupts an open stream', () async {
    fixture.stream = ': keepalive\n\n';
    fixture.holdStream = true;
    final gateway = OpenAiGateway(
      bearer: () async => 'fixture-key',
      apiBase: fixture.api,
    );
    addTearDown(gateway.close);
    final response = gateway.respond(
      model: 'gpt-fixture',
      instructions: '',
      input: [],
      tools: [],
    );
    final assertion = expectLater(response, throwsA(failure('cancelled')));
    await fixture.streamStarted.future;
    gateway.cancel();
    await assertion;
  });

  test(
    'dynamic registration validates PKCE and identity; reauth retains client and host',
    () async {
      final storage = MemoryCredentials();
      final manager = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      expect(storage.reads, 0);
      await Future.wait([manager.initialize(), manager.initialize()]);
      expect(storage.reads, 1);
      await manager.signInChatGpt();
      expect(manager.isConnected, true);
      expect(manager.needsPlanWelcome, true);
      await manager.acknowledgePlanWelcome();
      expect(manager.needsPlanWelcome, false);
      final first = fixture.authorizations.first.queryParameters;
      expect(first['client_id'], 'dynamic_agent_client');
      expect(first['agent_name_hint'], 'YAM');
      expect(
        first['ext_agent_host_id'],
        matches(
          RegExp(
            r'^urn:uuid:[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
      expect(Uri.parse(first['redirect_uri']!).host, '127.0.0.1');
      expect(Uri.parse(first['redirect_uri']!).path, '/auth/callback');
      await manager.signInChatGpt();
      final second = fixture.authorizations.last.queryParameters;
      expect(second['client_id'], 'oaiapp_fixture');
      expect(second.containsKey('agent_name_hint'), false);
      expect(second['ext_agent_host_id'], first['ext_agent_host_id']);
      expect(second['id_token_hint'], isNotEmpty);
      expect(second['state'], isNot(first['state']));
      expect(second['nonce'], isNot(first['nonce']));
      expect(manager.needsPlanWelcome, false);
      await manager.disconnect();
      expect(fixture.revocations, 1);
      expect(manager.isConnected, false);
      expect(storage.value, isNot(contains('fixture-refresh')));
      expect(storage.value, contains('oaiapp_fixture'));
      await manager.signInChatGpt();
      expect(
        fixture.authorizations.last.queryParameters.containsKey(
          'id_token_hint',
        ),
        false,
      );
      expect(
        fixture.authorizations.last.queryParameters['client_id'],
        'oaiapp_fixture',
      );
    },
  );

  for (final invalid in [
    'issuer',
    'audience',
    'expiry',
    'nonce',
    'email',
    'signature',
    'state',
  ]) {
    test(
      'rejects $invalid without replacing verified active credentials',
      () async {
        final storage = MemoryCredentials();
        final manager = AssistantConnectionManager(
          storage: storage,
          apiBase: fixture.api,
          oauthIssuer: fixture.issuer,
          openBrowser: fixture.browser,
          now: () => fixture.clock,
        );
        addTearDown(manager.dispose);
        await manager.initialize();
        await manager.signInChatGpt();
        final before = storage.value;
        fixture.invalidClaim = invalid;
        fixture.badSignature = invalid == 'signature';
        fixture.badState = invalid == 'state';
        final exchangeCount = fixture.exchanges.length;
        await expectLater(manager.signInChatGpt(), throwsA(failure('auth')));
        expect(storage.value, before);
        expect(manager.isConnected, true);
        if (invalid == 'state') expect(fixture.exchanges.length, exchangeCount);
      },
    );
  }

  test(
    'returning account cannot replace subject, access denied does not exchange code',
    () async {
      final manager = AssistantConnectionManager(
        storage: MemoryCredentials(),
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await manager.signInChatGpt();
      final label = manager.accountLabel;
      fixture.subject = 'different-user';
      await expectLater(manager.signInChatGpt(), throwsA(failure('auth')));
      expect(manager.accountLabel, label);
      fixture.deny = true;
      final exchanges = fixture.exchanges.length;
      await expectLater(
        manager.signInChatGpt(),
        throwsA(failure('permission')),
      );
      expect(fixture.exchanges.length, exchanges);
    },
  );

  test(
    'switching mode cancels old inference but persists in-flight token rotation',
    () async {
      final storage = MemoryCredentials();
      final manager = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await manager.connectApiKey('fixture-own-key');
      await manager.signInChatGpt();
      fixture.clock = fixture.clock.add(const Duration(hours: 2));
      final oldRequest = manager.gateway.listModels();
      final assertion = expectLater(oldRequest, throwsA(failure('cancelled')));
      await fixture.refreshStarted.future;
      await manager.selectMode(AssistantConnectionMode.apiKey);
      await assertion;
      expect(storage.value, contains('fixture-refresh-1'));
      expect(manager.mode, AssistantConnectionMode.apiKey);
      expect(fixture.bearerHeaders.last, 'Bearer fixture-own-key');
      await manager.selectMode(AssistantConnectionMode.chatgpt);
      expect(fixture.bearerHeaders.last, 'Bearer fixture-access-1');
      expect(fixture.refreshes, 1);
    },
  );

  test(
    'refresh serializes rotation and transcription uses retained own key in OAuth mode',
    () async {
      final storage = MemoryCredentials();
      final manager = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await manager.connectApiKey('fixture-own-key');
      await manager.signInChatGpt();
      fixture.clock = fixture.clock.add(const Duration(hours: 2));
      await Future.wait([
        manager.gateway.listModels(),
        manager.gateway.listModels(),
      ]);
      expect(fixture.refreshes, 1);
      expect(fixture.exchanges.last['refresh_token'], 'fixture-refresh-0');
      expect(storage.value, contains('fixture-refresh-1'));
      expect(fixture.bearerHeaders.last, 'Bearer fixture-access-1');
      expect(
        await manager.transcribe(
          Uint8List.fromList([1, 2, 3]),
          filename: 'voice.wav',
          mimeType: 'audio/wav',
        ),
        'яблоко',
      );
      expect(fixture.transcriptionBearer, 'Bearer fixture-own-key');
      expect(fixture.multipart, contains('gpt-transcribe'));
      await manager.disconnect();
      expect(manager.hasApiKey, true);
      await manager.selectMode(AssistantConnectionMode.apiKey);
      expect(manager.isConnected, true);
    },
  );

  test(
    'invalid grant retains issued registration for reauthorization, not dynamic sentinel',
    () async {
      final storage = MemoryCredentials();
      final manager = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      fixture.rejectGrant = true;
      await expectLater(manager.signInChatGpt(), throwsA(failure('auth')));
      expect(manager.isConnected, false);
      expect(storage.value, contains('oaiapp_fixture'));
      fixture.rejectGrant = false;
      await manager.signInChatGpt();
      expect(
        fixture.authorizations.last.queryParameters['client_id'],
        'oaiapp_fixture',
      );
      fixture.rejectRefresh = true;
      fixture.clock = fixture.clock.add(const Duration(hours: 2));
      await expectLater(manager.gateway.listModels(), throwsA(failure('auth')));
      expect(manager.isConnected, false);
      expect(storage.value, isNot(contains('fixture-refresh')));
    },
  );

  test(
    'identity without granted ChatGPT plan scope never enables inference',
    () async {
      fixture.omitPlanScope = true;
      final manager = AssistantConnectionManager(
        storage: MemoryCredentials(),
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await expectLater(
        manager.signInChatGpt(),
        throwsA(failure('permission')),
      );
      expect(manager.isConnected, false);
      expect(fixture.bearerHeaders, isEmpty);
    },
  );

  test(
    'cancel closes pending loopback authorization without a code exchange',
    () async {
      final opened = Completer<void>();
      final oauth = ChatGptOAuth(
        issuer: fixture.issuer,
        openBrowser: (uri) async {
          opened.complete();
          return true;
        },
      );
      addTearDown(oauth.close);
      final attempt = oauth.authorize(
        hostId: 'urn:uuid:fixture',
        onIssuedClient: (_) async {},
      );
      final assertion = expectLater(attempt, throwsA(failure('cancelled')));
      await opened.future;
      oauth.cancel();
      await assertion;
      expect(fixture.exchanges, isEmpty);
    },
  );

  test(
    'plan welcome and own key survive a new manager through protected storage',
    () async {
      final storage = MemoryCredentials();
      final manager = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(manager.dispose);
      await manager.initialize();
      await manager.connectApiKey('fixture-own-key');
      await manager.signInChatGpt();
      await manager.acknowledgePlanWelcome();
      final resumed = AssistantConnectionManager(
        storage: storage,
        apiBase: fixture.api,
        oauthIssuer: fixture.issuer,
        openBrowser: fixture.browser,
        now: () => fixture.clock,
      );
      addTearDown(resumed.dispose);
      await resumed.initialize();
      expect(resumed.mode, AssistantConnectionMode.chatgpt);
      expect(resumed.isConnected, true);
      expect(resumed.hasApiKey, true);
      expect(resumed.needsPlanWelcome, false);
    },
  );

  test('errors expose sanitized codes, never provider body', () async {
    fixture.failModels = true;
    final manager = AssistantConnectionManager(
      storage: MemoryCredentials(),
      apiBase: fixture.api,
    );
    addTearDown(manager.dispose);
    await manager.initialize();
    await expectLater(
      manager.connectApiKey('fixture-key'),
      throwsA(failure('auth')),
    );
    expect(manager.failureCode, 'auth');
    expect(manager.hasApiKey, false);
  });
}
