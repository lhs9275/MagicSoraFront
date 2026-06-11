import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('BffAuthService', () {
    test('카카오 토큰을 BFF 계약에 맞춰 교환한다', () async {
      final service = BffAuthService(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/mapi/auth/kakao'),
          );
          expect(request.headers['Content-Type'], 'application/json');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {'kakaoAccessToken': 'kakao-token'});

          return http.Response(
            jsonEncode({
              'token_type': 'Bearer',
              'access_token': 'bff-access',
              'refresh_token': 'bff-refresh',
            }),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      final session = await service.exchangeKakaoAccessToken(
        kakaoAccessToken: 'kakao-token',
        fallbackUser: AppUser.kakao(
          nickname: 'fallback',
          email: 'fallback@example.com',
          profileImageUrl: null,
        ),
      );

      expect(session.accessToken, 'bff-access');
      expect(session.refreshToken, 'bff-refresh');
      expect(session.user.nickname, 'fallback');
    });

    test('이메일/비밀번호 로그인은 POST /mapi/auth/token JSON으로 요청한다', () async {
      final service = BffAuthService(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/mapi/auth/token'),
          );
          expect(request.headers['Content-Type'], 'application/json');

          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {
            'username': 'me@example.com',
            'password': 'p@ssw0rd!',
          });

          return http.Response(
            jsonEncode({
              'token_type': 'Bearer',
              'access_token': 'access-1',
              'access_token_expires_in': 600,
              'refresh_token': 'refresh-1',
              'refresh_token_expires_in': 86400,
            }),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      final session = await service.loginWithEmailPassword(
        email: 'me@example.com',
        password: 'p@ssw0rd!',
        fallbackUser: AppUser.fallback,
      );

      expect(session.accessToken, 'access-1');
      expect(session.refreshToken, 'refresh-1');
      expect(session.user.email, 'me@example.com');
      expect(session.user.loginProvider, 'EMAIL');
      expect(session.user.isDemo, isFalse);
    });

    test('회원가입은 POST /user를 form-encoded로 보낸다', () async {
      final service = BffAuthService(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url, Uri.parse('https://bff.noctide.dev/user'));
          expect(
            request.headers['Content-Type'],
            contains('application/x-www-form-urlencoded'),
          );

          final decoded = Uri.splitQueryString(request.body);
          expect(decoded, {
            'email': 'new@example.com',
            'password': 'secret123',
            'name': '소라사용자',
          });

          return http.Response('', 201);
        }),
      );

      await expectLater(
        service.signUpWithEmail(
          email: 'new@example.com',
          password: 'secret123',
          name: '소라사용자',
        ),
        completes,
      );
    });

    test('회원가입 409면 BffAuthException으로 매핑된다', () async {
      final service = BffAuthService(
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode({'message': 'email taken'}),
            409,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.signUpWithEmail(
          email: 'dup@example.com',
          password: 'secret123',
          name: '중복',
        ),
        throwsA(
          isA<BffAuthException>()
              .having((e) => e.statusCode, 'statusCode', 409)
              .having((e) => e.message, 'message', 'email taken'),
        ),
      );
    });

    test('refreshSession은 저장된 refresh_token으로 새 access를 발급받는다', () async {
      await AuthSessionStore.instance.saveSession(
        const AuthSession(
          accessToken: 'old-access',
          refreshToken: 'r-1',
          user: AppUser.fallback,
        ),
      );

      final service = BffAuthService(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/mapi/auth/refresh'),
          );
          expect(request.headers['Content-Type'], 'application/json');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {'refresh_token': 'r-1'});

          return http.Response(
            jsonEncode({
              'access_token': 'new-access',
              'refresh_token': 'r-2',
              'token_type': 'Bearer',
            }),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      final updated = await service.refreshSession();

      expect(updated, isNotNull);
      expect(updated!.accessToken, 'new-access');
      expect(updated.refreshToken, 'r-2');
      expect(AuthSessionStore.instance.currentSession?.accessToken, 'new-access');
    });

    test('refresh 실패 시 null을 반환하고 세션은 유지된다', () async {
      await AuthSessionStore.instance.saveSession(
        const AuthSession(
          accessToken: 'old-access',
          refreshToken: 'r-1',
          user: AppUser.fallback,
        ),
      );

      final service = BffAuthService(
        httpClient: MockClient((request) async {
          return http.Response('', 401);
        }),
      );

      expect(await service.refreshSession(), isNull);
      expect(AuthSessionStore.instance.currentSession?.accessToken, 'old-access');
    });
  });
}
