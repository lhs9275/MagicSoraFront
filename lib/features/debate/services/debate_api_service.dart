import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:magicsorafront/core/config/bff_config.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';

class DebateApiService {
  DebateApiService({
    http.Client? httpClient,
    AuthSessionStore? sessionStore,
    BffAuthService? authService,
    List<Duration>? streamRetryDelays,
  }) : _httpClient = httpClient ?? http.Client(),
       _sessionStore = sessionStore ?? AuthSessionStore.instance,
       _authService =
           authService ??
           BffAuthService(
             httpClient: httpClient,
             sessionStore: sessionStore ?? AuthSessionStore.instance,
           ),
       _streamRetryDelays = List.unmodifiable(
         streamRetryDelays ??
             const [Duration(milliseconds: 300), Duration(seconds: 1)],
       );

  final http.Client _httpClient;
  final AuthSessionStore _sessionStore;
  final BffAuthService _authService;
  final List<Duration> _streamRetryDelays;

  /// 가이드 1.2: 만료된 access token으로 401을 받으면 refresh를 1회 시도하고 재요청한다.
  Future<T> _withTokenRefresh<T>(Future<T> Function() perform) async {
    try {
      return await perform();
    } on DebateApiException catch (error) {
      if (error.statusCode != 401) {
        rethrow;
      }
      final refreshed = await _authService.refreshSession();
      if (refreshed == null) {
        rethrow;
      }
      return await perform();
    }
  }

  Future<int> startDebate(String topic) {
    return _withTokenRefresh(() => _startDebateOnce(topic));
  }

  Future<int> _startDebateOnce(String topic) async {
    final response = await _httpClient
        .post(
          BffConfig.apiUri('/api/debates'),
          headers: await _jsonHeaders(),
          body: jsonEncode({'topic': topic}),
        )
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    if (response.statusCode == 429) {
      throw DebateApiException(
        _firstNonEmptyString([body['message'], body['error']]) ??
            '동시에 진행할 수 있는 토론 수를 초과했어요. 진행 중인 토론을 마친 뒤 다시 시도해주세요.',
        statusCode: 429,
      );
    }

    _throwIfFailed(response.statusCode, body, '/api/debates');

    final debateId = _asInt(body['debateId']);
    if (debateId == null || debateId < 1) {
      throw const DebateApiException('토론 생성 응답에서 debateId를 찾지 못했습니다.');
    }
    return debateId;
  }

  Stream<DebateSseEvent> streamDebate(int debateId) async* {
    final path = '/api/debates/$debateId/stream';
    final response = await _withTokenRefresh(() => _openDebateStream(path));
    yield* _parseSse(response.stream);
  }

  Future<DebateListPage> fetchDebates({int? cursor}) {
    return _withTokenRefresh(() => _fetchDebatesOnce(cursor: cursor));
  }

  Future<DebateListPage> _fetchDebatesOnce({int? cursor}) async {
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

  Future<DebateDetail> fetchDebate(int debateId) {
    return _withTokenRefresh(() => _fetchDebateOnce(debateId));
  }

  Future<DebateDetail> _fetchDebateOnce(int debateId) async {
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

  Future<DebateCancelResult> cancelDebate(int debateId) {
    return _withTokenRefresh(() => _cancelDebateOnce(debateId));
  }

  Future<DebateCancelResult> _cancelDebateOnce(int debateId) async {
    final path = '/api/debates/$debateId/cancel';
    final response = await _httpClient
        .post(BffConfig.apiUri(path), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 15));
    final body = _decodeJson(response.bodyBytes);

    _throwIfFailed(response.statusCode, body, path);
    return DebateCancelResult.fromJson(body);
  }

  Future<void> deleteDebate(int debateId) {
    return _withTokenRefresh(() => _deleteDebateOnce(debateId));
  }

  Future<void> _deleteDebateOnce(int debateId) async {
    final path = '/api/debates/$debateId';
    final response = await _httpClient
        .delete(BffConfig.apiUri(path), headers: await _jsonHeaders())
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    _throwIfFailed(response.statusCode, _decodeJson(response.bodyBytes), path);
  }

  Stream<DebateSseEvent> askQuestion(int debateId, String question) async* {
    final response = await _withTokenRefresh(
      () => _openQuestionStream(debateId, question),
    );
    yield* _parseSse(response.stream);
  }

  Future<http.StreamedResponse> _openQuestionStream(
    int debateId,
    String question,
  ) async {
    final path = '/api/debates/$debateId/questions';
    final headers = await _streamHeaders();
    headers['Content-Type'] = 'application/json';

    final request = http.Request('POST', BffConfig.apiUri(path));
    request.headers.addAll(headers);
    request.body = jsonEncode({'question': question});

    http.StreamedResponse response;
    try {
      response = await _httpClient
          .send(request)
          .timeout(const Duration(minutes: 2));
    } on TimeoutException {
      throw const DebateApiException('추가 질문 응답 시간이 초과되었습니다.');
    } on http.ClientException catch (error) {
      final detail = error.message.trim();
      throw DebateApiException(
        detail.isEmpty ? '추가 질문 요청에 실패했습니다.' : detail,
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final bodyText = await response.stream.bytesToString();
      throw DebateApiException(
        _messageFromBodyText(
          bodyText,
          fallback: _questionErrorMessage(response.statusCode),
        ),
        statusCode: response.statusCode,
      );
    }

    return response;
  }

  Future<List<DebateQuestionAnswer>> fetchQuestions(int debateId) {
    return _withTokenRefresh(() => _fetchQuestionsOnce(debateId));
  }

  Future<List<DebateQuestionAnswer>> _fetchQuestionsOnce(int debateId) async {
    final path = '/api/debates/$debateId/questions';
    final response = await _httpClient
        .get(
          BffConfig.apiUri(path),
          headers: await _jsonHeaders(contentType: false),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      _throwIfFailed(
        response.statusCode,
        _decodeJson(response.bodyBytes),
        path,
      );
    }

    final rawBody = utf8.decode(response.bodyBytes, allowMalformed: true).trim();
    if (rawBody.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(rawBody);
    if (decoded is! List) {
      return const [];
    }

    final results = <DebateQuestionAnswer>[];
    for (final item in decoded) {
      if (item is Map) {
        results.add(
          DebateQuestionAnswer.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
      }
    }
    return results;
  }

  String _questionErrorMessage(int statusCode) {
    return switch (statusCode) {
      400 => '추가 질문은 1~500자 사이여야 합니다.',
      401 => '로그인이 필요합니다.',
      403 => '본인 토론에만 추가 질문할 수 있습니다.',
      404 => '토론을 찾을 수 없습니다.',
      409 => '토론이 완료된 뒤에 추가 질문할 수 있어요.',
      429 => '잠시 후 다시 시도해주세요. (분당 5회 제한)',
      _ => '추가 질문에 실패했습니다. status=$statusCode',
    };
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
        // 가이드 3.3: endpoint별 공백 차이가 있어 event 이름은 trim해 비교한다.
        eventName = value.trim();
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

  Future<http.StreamedResponse> _openDebateStream(String path) async {
    final headers = await _streamHeaders();
    final totalAttempts = _streamRetryDelays.length + 1;
    DebateApiException? lastError;

    for (var attempt = 0; attempt < totalAttempts; attempt++) {
      if (attempt > 0) {
        await Future.delayed(_streamRetryDelays[attempt - 1]);
      }

      final request = http.Request('GET', BffConfig.apiUri(path));
      request.headers.addAll(headers);

      try {
        final response = await _httpClient
            .send(request)
            .timeout(const Duration(minutes: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return response;
        }

        final bodyText = await response.stream.bytesToString();
        final shouldRetry =
            attempt < totalAttempts - 1 &&
            _shouldRetryStreamStatusCode(response.statusCode);

        _logStreamConnectFailure(
          path: path,
          attempt: attempt + 1,
          totalAttempts: totalAttempts,
          statusCode: response.statusCode,
          bodyText: bodyText,
          nextDelay: shouldRetry ? _streamRetryDelays[attempt] : null,
        );

        lastError = DebateApiException(
          _messageFromBodyText(
            bodyText,
            fallback: _streamConnectFailureMessage(response.statusCode, path),
          ),
          statusCode: response.statusCode,
        );

        if (!shouldRetry) {
          throw lastError;
        }
      } on TimeoutException {
        final shouldRetry = attempt < totalAttempts - 1;
        lastError = DebateApiException(
          '토론 스트림 연결 시간이 초과되었습니다. timeout=10m path=$path',
        );

        _logStreamConnectFailure(
          path: path,
          attempt: attempt + 1,
          totalAttempts: totalAttempts,
          errorMessage: lastError.message,
          nextDelay: shouldRetry ? _streamRetryDelays[attempt] : null,
        );

        if (!shouldRetry) {
          throw lastError;
        }
      } on http.ClientException catch (error) {
        final shouldRetry = attempt < totalAttempts - 1;
        final detail = error.message.trim();
        lastError = DebateApiException(
          detail.isEmpty ? '토론 스트림 연결에 실패했습니다. path=$path' : detail,
        );

        _logStreamConnectFailure(
          path: path,
          attempt: attempt + 1,
          totalAttempts: totalAttempts,
          errorMessage: detail.isEmpty ? error.runtimeType.toString() : detail,
          nextDelay: shouldRetry ? _streamRetryDelays[attempt] : null,
        );

        if (!shouldRetry) {
          throw lastError;
        }
      }
    }

    throw lastError ?? DebateApiException('토론 스트림 연결에 실패했습니다. path=$path');
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

  bool _shouldRetryStreamStatusCode(int statusCode) {
    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  String _streamConnectFailureMessage(int statusCode, String path) {
    final baseMessage = statusCode >= 500
        ? '토론 서버 응답이 불안정합니다. 잠시 후 다시 시도해주세요.'
        : '토론 스트림 연결에 실패했습니다.';
    return '$baseMessage status=$statusCode path=$path';
  }

  void _logStreamConnectFailure({
    required String path,
    required int attempt,
    required int totalAttempts,
    int? statusCode,
    String? bodyText,
    String? errorMessage,
    Duration? nextDelay,
  }) {
    final summary = StringBuffer(
      '[DebateStream] connect failed path=$path attempt=$attempt/$totalAttempts',
    );

    if (statusCode != null) {
      summary.write(' status=$statusCode');
    }
    if (errorMessage != null && errorMessage.isNotEmpty) {
      summary.write(' error=$errorMessage');
    }
    if (nextDelay != null) {
      summary.write(' retryInMs=${nextDelay.inMilliseconds}');
    }

    final bodyPreview = _bodyPreviewForLog(bodyText);
    if (bodyPreview != null) {
      summary.write(' body=$bodyPreview');
    }

    developer.log(summary.toString(), name: 'DebateApiService');
  }

  String? _bodyPreviewForLog(String? bodyText) {
    final normalized = bodyText?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.length <= 240) {
      return normalized;
    }
    return '${normalized.substring(0, 240)}...';
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
