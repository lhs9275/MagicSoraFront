import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:magicsorafront/core/config/bff_config.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';

class DebateApiService {
  DebateApiService({http.Client? httpClient, AuthSessionStore? sessionStore})
    : _httpClient = httpClient ?? http.Client(),
      _sessionStore = sessionStore ?? AuthSessionStore.instance;

  final http.Client _httpClient;
  final AuthSessionStore _sessionStore;

  Future<int> startDebate(String topic) async {
    final response = await _httpClient
        .post(
          BffConfig.apiUri('/api/debates'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'topic': topic}),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    _throwIfFailed(response.statusCode, body, '/api/debates');

    final debateId = _asInt(body['debateId']);
    if (debateId == null || debateId < 1) {
      throw const DebateApiException('토론 생성 응답에서 debateId를 찾지 못했습니다.');
    }
    return debateId;
  }

  Stream<DebateSseEvent> streamDebate(int debateId) async* {
    final path = '/api/debates/$debateId/stream';
    final request = http.Request('GET', BffConfig.apiUri(path));
    request.headers.addAll(await _streamHeaders());

    final http.StreamedResponse response;
    try {
      response = await _httpClient
          .send(request)
          .timeout(const Duration(minutes: 10));
    } on TimeoutException {
      throw DebateApiException('토론 스트림 연결 시간이 초과되었습니다. timeout=10m path=$path');
    } on http.ClientException catch (error) {
      final detail = error.message.trim();
      throw DebateApiException(
        detail.isEmpty ? '토론 스트림 연결에 실패했습니다. path=$path' : detail,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final bodyText = await response.stream.bytesToString();
      throw DebateApiException(
        _messageFromBodyText(
          bodyText,
          fallback:
              '토론 스트림 연결에 실패했습니다. status=${response.statusCode} path=$path',
        ),
        statusCode: response.statusCode,
      );
    }

    yield* _parseSse(response.stream);
  }

  Future<DebateListPage> fetchDebates({int? cursor}) async {
    final response = await _httpClient
        .get(
          BffConfig.apiUri('/api/debates', queryParameters: {'cursor': cursor}),
          headers: await _jsonHeaders(contentType: false),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    _throwIfFailed(response.statusCode, body, '/api/debates');
    return DebateListPage.fromJson(body);
  }

  Future<DebateDetail> fetchDebate(int debateId) async {
    final path = '/api/debates/$debateId';
    final response = await _httpClient
        .get(
          BffConfig.apiUri(path),
          headers: await _jsonHeaders(contentType: false),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    _throwIfFailed(response.statusCode, body, path);
    return DebateDetail.fromJson(body);
  }

  Future<DebateCancelResult> cancelDebate(int debateId) async {
    final path = '/api/debates/$debateId/cancel';
    final response = await _httpClient
        .post(BffConfig.apiUri(path), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    _throwIfFailed(response.statusCode, body, path);
    return DebateCancelResult.fromJson(body);
  }

  Future<void> deleteDebate(int debateId) async {
    final path = '/api/debates/$debateId';
    final response = await _httpClient
        .delete(BffConfig.apiUri(path), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    _throwIfFailed(response.statusCode, _decodeJson(response.bodyBytes), path);
  }

  Stream<DebateSseEvent> _parseSse(Stream<List<int>> byteStream) async* {
    String? eventName;
    final dataLines = <String>[];

    await for (final line
        in byteStream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (eventName != null || dataLines.isNotEmpty) {
          yield DebateSseEvent(
            event: eventName ?? 'message',
            data: dataLines.join('\n'),
          );
        }
        eventName = null;
        dataLines.clear();
        continue;
      }

      if (line.startsWith(':')) {
        continue;
      }

      final separatorIndex = line.indexOf(':');
      final field = separatorIndex == -1
          ? line
          : line.substring(0, separatorIndex);
      var value = separatorIndex == -1
          ? ''
          : line.substring(separatorIndex + 1);
      if (value.startsWith(' ')) {
        value = value.substring(1);
      }

      if (field == 'event') {
        eventName = value;
      } else if (field == 'data') {
        dataLines.add(value);
      }
    }

    if (eventName != null || dataLines.isNotEmpty) {
      yield DebateSseEvent(
        event: eventName ?? 'message',
        data: dataLines.join('\n'),
      );
    }
  }

  Future<Map<String, String>> _jsonHeaders({bool contentType = true}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer ${await _accessToken()}',
    };
    if (contentType) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  Future<Map<String, String>> _streamHeaders() async {
    return {
      'Accept': 'text/event-stream',
      'Authorization': 'Bearer ${await _accessToken()}',
      'Cache-Control': 'no-cache',
    };
  }

  Future<String> _accessToken() async {
    final session =
        _sessionStore.currentSession ?? await _sessionStore.loadSession();
    final accessToken = session?.accessToken.trim() ?? '';
    if (accessToken.isEmpty) {
      throw const DebateApiException('로그인이 필요합니다.', statusCode: 401);
    }
    return accessToken;
  }

  Map<String, dynamic> _decodeJson(Uint8List bodyBytes) {
    if (bodyBytes.isEmpty) {
      return const {};
    }

    final rawBody = utf8.decode(bodyBytes, allowMalformed: true).trim();
    if (rawBody.isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    return {'data': decoded};
  }

  void _throwIfFailed(
    int statusCode,
    Map<String, dynamic> body,
    String fallbackPath,
  ) {
    if (statusCode >= 200 && statusCode < 300) {
      return;
    }

    final message =
        _firstNonEmptyString([
          body['message'],
          body['error'],
          body['detail'],
        ]) ??
        'BFF 요청에 실패했습니다. status=$statusCode path=$fallbackPath';
    throw DebateApiException(message, statusCode: statusCode);
  }

  String _messageFromBodyText(String bodyText, {required String fallback}) {
    final raw = bodyText.trim();
    if (raw.isEmpty) {
      return fallback;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return _firstNonEmptyString([
              decoded['message'],
              decoded['error'],
              decoded['detail'],
            ]) ??
            fallback;
      }
    } on FormatException {
      return raw;
    }

    return fallback;
  }

  String? _firstNonEmptyString(Iterable<Object?> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}

class DebateApiException implements Exception {
  const DebateApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}
