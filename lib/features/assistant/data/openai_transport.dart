import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yam/features/assistant/domain/assistant_models.dart';

/// Only stable, app-owned codes leave the transport boundary.
AssistantFailure assistantHttpFailure(int status, dynamic body) {
  final error = body is Map ? body['error'] : null;
  final code = error is Map ? error['code'] ?? error['type'] : error;
  return AssistantFailure(switch (code) {
    'subscription_sharing_usage_limit_exceeded' ||
    'insufficient_quota' => 'usage_limit',
    'subscription_sharing_usage_unavailable' => 'usage_unavailable',
    'invalid_api_key' || 'invalid_grant' || 'invalid_token' => 'auth',
    'access_denied' || 'insufficient_scope' => 'permission',
    'rate_limit_exceeded' => 'rate_limit',
    _ => switch (status) {
      401 => 'auth',
      403 => 'permission',
      429 => 'rate_limit',
      >= 500 => 'network',
      _ => 'protocol',
    },
  });
}

Future<dynamic> readAssistantJson(HttpClientResponse response) async {
  try {
    final body = await utf8.decoder
        .bind(response)
        .join()
        .timeout(const Duration(seconds: 30));
    final dynamic value = body.isEmpty ? null : jsonDecode(body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw assistantHttpFailure(response.statusCode, value);
    }
    return value;
  } on AssistantFailure {
    rethrow;
  } on FormatException {
    throw assistantHttpFailure(response.statusCode, null);
  } on TimeoutException {
    throw const AssistantFailure('network');
  } on IOException {
    throw const AssistantFailure('network');
  }
}

/// SSE framing is independent of socket chunks and supports multi-line data.
Stream<String> assistantSseData(Stream<List<int>> bytes) async* {
  final data = <String>[];
  await for (final line
      in bytes.transform(utf8.decoder).transform(const LineSplitter())) {
    if (line.isEmpty) {
      if (data.isNotEmpty) {
        yield data.join('\n');
        data.clear();
      }
    } else if (line.startsWith('data:')) {
      var value = line.substring(5);
      if (value.startsWith(' ')) value = value.substring(1);
      data.add(value);
    }
  }
  // An unterminated event is not dispatched, per the SSE protocol.
}

class OpenAiGateway implements AssistantGateway {
  OpenAiGateway({
    required Future<String> Function() bearer,
    Uri? apiBase,
    HttpClient Function()? httpClientFactory,
    bool Function()? useNamespaces,
  }) : _bearer = bearer,
       _apiBase = apiBase ?? Uri.parse('https://api.openai.com/v1/'),
       _clientFactory = httpClientFactory ?? HttpClient.new,
       _useNamespaces = useNamespaces ?? (() => true);

  final Future<String> Function() _bearer;
  final Uri _apiBase;
  final HttpClient Function() _clientFactory;
  final bool Function() _useNamespaces;
  final Set<HttpClient> _clients = {};
  int _generation = 0;
  bool _closed = false;

  Future<HttpClientResponse> _request(
    HttpClient client,
    String method,
    String path,
    String token, {
    Map<String, dynamic>? body,
  }) async {
    final request = await client
        .openUrl(method, _apiBase.resolve(path))
        .timeout(const Duration(seconds: 30));
    request.followRedirects = false;
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
      request.write(jsonEncode(body));
    }
    return request.close().timeout(const Duration(seconds: 60));
  }

  @override
  Future<List<AssistantModel>> listModels() async {
    if (_closed) throw const AssistantFailure('cancelled');
    final client = _clientFactory();
    _clients.add(client);
    try {
      final token = await _bearer();
      final value = await readAssistantJson(
        await _request(client, 'GET', 'models', token),
      );
      if (value is! Map) throw const AssistantFailure('protocol');
      final oauth = value['models'] is List;
      final rows = oauth ? value['models'] : value['data'];
      if (rows is! List) throw const AssistantFailure('protocol');
      final models = <AssistantModel>[];
      for (final row in rows.whereType<Map>()) {
        final id = row[oauth ? 'slug' : 'id'];
        if (id is! String || (oauth && row['visibility'] != 'list')) continue;
        if (!_supportsFoodAssistant(id, row, oauth: oauth)) continue;
        final label = row['display_name'];
        models.add(AssistantModel(id: id, label: label is String ? label : id));
      }
      if (models.isEmpty) throw const AssistantFailure('no_models');
      return models;
    } on AssistantFailure {
      rethrow;
    } on TimeoutException {
      throw const AssistantFailure('network');
    } on IOException {
      throw const AssistantFailure('network');
    } on FormatException {
      throw const AssistantFailure('protocol');
    } finally {
      _clients.remove(client);
      client.close(force: true);
    }
  }

  // The ordinary catalog has no modality/endpoint metadata. Restrict known
  // general-purpose families, excluding specialized variants, not entitlements.
  bool _supportsFoodAssistant(String id, Map row, {required bool oauth}) {
    final lower = id.toLowerCase();
    if (RegExp(
          r'(^|[-_])(audio|realtime|transcribe|transcription|tts|embedding|search|image|codex|moderation|instruct)([-_]|$)',
        ).hasMatch(lower) ||
        lower.startsWith('dall-e') ||
        lower.startsWith('whisper') ||
        lower.startsWith('chatgpt-') ||
        lower.startsWith('gpt-3.5') ||
        lower == 'gpt-4' ||
        lower.startsWith('gpt-4-') ||
        lower.startsWith('o1') ||
        lower.startsWith('o3-mini')) {
      return false;
    }
    final capabilities = row['capabilities'];
    if (capabilities is Map &&
        (capabilities['tools'] == false ||
            capabilities['vision'] == false ||
            capabilities['responses'] == false)) {
      return false;
    }
    return oauth || RegExp(r'^(gpt-(4o|4\.1|[5-9])|o[3-9])').hasMatch(lower);
  }

  @override
  Future<AssistantTurn> respond({
    required String model,
    required String instructions,
    required List<Map<String, dynamic>> input,
    required List<Map<String, dynamic>> tools,
    void Function(String delta)? onText,
  }) async {
    if (_closed) throw const AssistantFailure('cancelled');
    final generation = _generation;
    final client = _clientFactory();
    _clients.add(client);
    try {
      final token = await _bearer();
      if (generation != _generation) throw const AssistantFailure('cancelled');
      final useNamespaces = _useNamespaces();
      if (tools.any(
        (tool) =>
            tool['type'] != 'function' &&
            (tool['type'] != 'namespace' || !useNamespaces),
      )) {
        throw const AssistantFailure('protocol');
      }
      var requestTools = tools;
      if (useNamespaces) {
        final functions = tools
            .where((tool) => tool['type'] == 'function')
            .toList();
        requestTools = [
          ...tools.where((tool) => tool['type'] == 'namespace'),
          if (functions.isNotEmpty)
            {
              'type': 'namespace',
              'name': 'yam',
              'description':
                  'YAM food lookup and editable diary draft tools. No direct writes.',
              'tools': functions,
            },
        ];
      }
      final response = await _request(
        client,
        'POST',
        'responses',
        token,
        body: {
          'model': model,
          'instructions': instructions,
          'input': input,
          'tools': requestTools,
          'store': false,
          'stream': true,
          'include': ['reasoning.encrypted_content'],
        },
      );
      if (response.statusCode != 200) {
        await readAssistantJson(response);
        throw const AssistantFailure('protocol');
      }
      if (response.headers.contentType?.mimeType != 'text/event-stream') {
        throw const AssistantFailure('protocol');
      }
      await for (final data in assistantSseData(
        response,
      ).timeout(const Duration(seconds: 90))) {
        if (generation != _generation) {
          throw const AssistantFailure('cancelled');
        }
        if (data == '[DONE]') break;
        final dynamic event = jsonDecode(data);
        if (event is! Map) throw const AssistantFailure('protocol');
        switch (event['type']) {
          case 'response.output_text.delta':
            if (event['delta'] is String) {
              onText?.call(event['delta'] as String);
            }
          case 'response.completed':
            final completed = event['response'];
            if (completed is! Map ||
                completed['status'] != 'completed' ||
                completed['output'] is! List) {
              throw const AssistantFailure('protocol');
            }
            final output = completed['output'] as List;
            if (output.any((item) => item is! Map<String, dynamic>)) {
              throw const AssistantFailure('protocol');
            }
            return AssistantTurn(output: output.cast<Map<String, dynamic>>());
          case 'response.failed':
            throw assistantHttpFailure(400, event['response']);
          case 'response.incomplete':
            throw const AssistantFailure('incomplete');
          case 'error':
            throw assistantHttpFailure(400, {'error': event});
        }
      }
      throw AssistantFailure(
        generation != _generation ? 'cancelled' : 'interrupted',
      );
    } on AssistantFailure {
      rethrow;
    } on FormatException {
      throw const AssistantFailure('protocol');
    } on TimeoutException {
      throw AssistantFailure(
        generation != _generation ? 'cancelled' : 'network',
      );
    } on IOException {
      throw AssistantFailure(
        generation != _generation ? 'cancelled' : 'interrupted',
      );
    } finally {
      _clients.remove(client);
      client.close(force: true);
    }
  }

  @override
  void cancel() {
    _generation++;
    for (final client in _clients.toList()) {
      client.close(force: true);
    }
  }

  @override
  void close() {
    _closed = true;
    cancel();
  }
}
