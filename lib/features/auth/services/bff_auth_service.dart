import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:magicsorafront/core/config/bff_config.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';

/// 카카오/이메일 로그인, 회원가입, 토큰 갱신을 담당한다.
class BffAuthService {
  BffAuthService({http.Client? httpClient, AuthSessionStore? sessionStore})
    : _httpClient = httpClient ?? http.Client(),
      _sessionStore = sessionStore ?? AuthSessionStore.instance;

  final http.Client _httpClient;
  final AuthSessionStore _sessionStore;

  Future<AuthSession> exchangeKakaoAccessToken({
    required String kakaoAccessToken,
    required AppUser fallbackUser,
  }) async {
    if (!BffConfig.hasBaseUrl) {
      throw const BffAuthException(
        'BFF 주소가 없습니다. --dart-define=BFF_BASE_URL=https://your-bff 로 실행해주세요.',
      );
    }

    final response = await _postKakaoLoginRequest(kakaoAccessToken);
    final responseBody = _decodeResponseBody(response.bodyBytes);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BffAuthException(
        _errorMessageFor(
          statusCode: response.statusCode,
          responseBody: responseBody,
        ),
        statusCode: response.statusCode,
      );
    }

    return _parseAuthSession(
      responseBody: responseBody,
      fallbackUser: fallbackUser,
    );
  }

  /// 가이드 1.2: POST /mapi/auth/token (JSON) — username/password로 access/refresh 토큰 발급.
  Future<AuthSession> loginWithEmailPassword({
    required String email,
    required String password,
    required AppUser fallbackUser,
  }) async {
    _ensureBaseUrl();

    final response = await _postJson(
      path: '/mapi/auth/token',
      body: {'username': email, 'password': password},
      errorContext: '이메일 로그인',
    );

    final responseBody = _decodeResponseBody(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BffAuthException(
        _errorMessageFor(
          statusCode: response.statusCode,
          responseBody: responseBody,
        ),
        statusCode: response.statusCode,
      );
    }

    return _parseAuthSession(
      responseBody: responseBody,
      fallbackUser: fallbackUser.copyWith(
        email: email,
        loginProvider: 'EMAIL',
        isDemo: false,
      ),
    );
  }

  /// 가이드 1.1: POST /user (form-encoded) — email/password/name. 201 응답.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    _ensureBaseUrl();

    http.Response response;
    try {
      response = await _httpClient
          .post(
            BffConfig.apiUri('/user'),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: {'email': email, 'password': password, 'name': name},
          )
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const BffAuthException('BFF 서버에 연결하지 못했습니다. 주소와 네트워크를 확인해주세요.');
    } on TimeoutException {
      throw const BffAuthException('BFF 서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
    } on FormatException {
      throw const BffAuthException(
        'BFF 주소 형식이 잘못되었습니다. BFF_BASE_URL 값을 확인해주세요.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final responseBody = _decodeResponseBody(response.bodyBytes);
    throw BffAuthException(
      _errorMessageFor(
        statusCode: response.statusCode,
        responseBody: responseBody,
      ),
      statusCode: response.statusCode,
    );
  }

  /// 가이드 1.2: 만료 시 POST /mapi/auth/refresh로 access token 갱신.
  /// 성공 시 새 세션을 저장하고 반환. 실패 시 null.
  Future<AuthSession?> refreshSession() async {
    final session = await _sessionStore.loadSession();
    final refreshToken = session?.refreshToken?.trim() ?? '';
    if (session == null || refreshToken.isEmpty) {
      return null;
    }

    if (!BffConfig.hasBaseUrl) {
      return null;
    }

    http.Response response;
    try {
      response = await _postJson(
        path: '/mapi/auth/refresh',
        body: {'refresh_token': refreshToken},
        errorContext: '토큰 갱신',
      );
    } on BffAuthException {
      return null;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final responseBody = _decodeResponseBody(response.bodyBytes);
    final payload = _nestedPayload(responseBody);
    final newAccess = _firstNonEmptyString(<Object?>[
      payload['access_token'],
      payload['accessToken'],
      responseBody['access_token'],
      responseBody['accessToken'],
    ]);

    if (newAccess == null || newAccess.isEmpty) {
      return null;
    }

    final newRefresh =
        _firstNonEmptyString(<Object?>[
          payload['refresh_token'],
          payload['refreshToken'],
          responseBody['refresh_token'],
          responseBody['refreshToken'],
        ]) ??
        refreshToken;

    final updated = session.copyWith(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );
    await _sessionStore.saveSession(updated);
    return updated;
  }

  Future<http.Response> _postJson({
    required String path,
    required Map<String, Object?> body,
    required String errorContext,
  }) async {
    try {
      return await _httpClient
          .post(
            BffConfig.apiUri(path),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw BffAuthException('$errorContext 요청 중 BFF에 연결하지 못했습니다.');
    } on TimeoutException {
      throw BffAuthException('$errorContext 요청 응답이 지연되고 있습니다.');
    } on FormatException {
      throw const BffAuthException(
        'BFF 주소 형식이 잘못되었습니다. BFF_BASE_URL 값을 확인해주세요.',
      );
    }
  }

  void _ensureBaseUrl() {
    if (!BffConfig.hasBaseUrl) {
      throw const BffAuthException(
        'BFF 주소가 없습니다. --dart-define=BFF_BASE_URL=https://your-bff 로 실행해주세요.',
      );
    }
  }

  Future<http.Response> _postKakaoLoginRequest(String kakaoAccessToken) async {
    try {
      return await _httpClient
          .post(
            BffConfig.kakaoLoginUri(),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'kakaoAccessToken': kakaoAccessToken}),
          )
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const BffAuthException('BFF 서버에 연결하지 못했습니다. 주소와 네트워크를 확인해주세요.');
    } on TimeoutException {
      throw const BffAuthException('BFF 서버 응답이 지연되고 있습니다. 잠시 후 다시 시도해주세요.');
    } on FormatException {
      throw const BffAuthException(
        'BFF 주소 형식이 잘못되었습니다. BFF_BASE_URL 값을 확인해주세요.',
      );
    }
  }

  AuthSession _parseAuthSession({
    required Map<String, dynamic> responseBody,
    required AppUser fallbackUser,
  }) {
    final payload = _nestedPayload(responseBody);
    final accessToken =
        _firstNonEmptyString(<Object?>[
          payload['accessToken'],
          payload['access_token'],
          payload['token'],
          payload['jwt'],
          _asStringKeyedMap(payload['tokens'])['accessToken'],
          _asStringKeyedMap(payload['tokens'])['access_token'],
          _asStringKeyedMap(payload['token'])['accessToken'],
          responseBody['accessToken'],
          responseBody['access_token'],
        ]) ??
        '';

    if (accessToken.isEmpty) {
      throw const BffAuthException(
        'BFF 응답에서 accessToken을 찾지 못했습니다. 응답 필드 이름을 확인해주세요.',
      );
    }

    final refreshToken = _firstNonEmptyString(<Object?>[
      payload['refreshToken'],
      payload['refresh_token'],
      _asStringKeyedMap(payload['tokens'])['refreshToken'],
      _asStringKeyedMap(payload['tokens'])['refresh_token'],
      responseBody['refreshToken'],
      responseBody['refresh_token'],
    ]);

    final userMap = _asStringKeyedMap(payload['user']).isNotEmpty
        ? _asStringKeyedMap(payload['user'])
        : _asStringKeyedMap(responseBody['user']);

    final parsedUser = _parseUser(userMap);

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: parsedUser ?? fallbackUser,
    );
  }

  String _errorMessageFor({
    required int statusCode,
    required Map<String, dynamic> responseBody,
  }) {
    final payload = _nestedPayload(responseBody);
    final serverMessage = _firstNonEmptyString(<Object?>[
      payload['message'],
      payload['error'],
      payload['detail'],
      responseBody['message'],
      responseBody['error'],
    ]);

    if (serverMessage != null) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return 'BFF가 카카오 토큰 요청값을 이해하지 못했습니다.';
      case 401:
        return 'BFF가 카카오 토큰을 인정하지 않았습니다. 로그인 엔드포인트 permitAll 과 토큰 검증 로직을 확인해주세요.';
      case 403:
        return 'BFF 접근이 거부되었습니다. CORS 또는 보안 정책을 확인해주세요.';
      case 404:
        return 'BFF 로그인 경로를 찾지 못했습니다. BFF_KAKAO_LOGIN_PATH 값을 확인해주세요.';
      default:
        return 'BFF 로그인에 실패했습니다. status=$statusCode';
    }
  }

  Map<String, dynamic> _decodeResponseBody(Uint8List bodyBytes) {
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

  Map<String, dynamic> _nestedPayload(Map<String, dynamic> responseBody) {
    for (final key in const ['data', 'result', 'payload']) {
      final nested = _asStringKeyedMap(responseBody[key]);
      if (nested.isNotEmpty) {
        return nested;
      }
    }

    return responseBody;
  }

  AppUser? _parseUser(Map<String, dynamic> userMap) {
    if (userMap.isEmpty) {
      return null;
    }

    final nickname = _firstNonEmptyString(<Object?>[
      userMap['nickname'],
      userMap['name'],
      userMap['displayName'],
    ]);
    final email = _firstNonEmptyString(<Object?>[
      userMap['email'],
      userMap['accountEmail'],
    ]);
    final profileImageUrl = _firstNonEmptyString(<Object?>[
      userMap['profileImageUrl'],
      userMap['profile_image_url'],
      userMap['thumbnailImageUrl'],
      userMap['avatarUrl'],
    ]);
    final loginProvider =
        _firstNonEmptyString(<Object?>[
          userMap['loginProvider'],
          userMap['provider'],
        ]) ??
        '카카오';

    return AppUser(
      nickname: nickname ?? '카카오 사용자',
      email: email,
      profileImageUrl: profileImageUrl,
      loginProvider: loginProvider,
      isDemo: false,
    );
  }

  Map<String, dynamic> _asStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(key.toString(), nestedValue),
      );
    }

    return const {};
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

class BffAuthException implements Exception {
  const BffAuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
