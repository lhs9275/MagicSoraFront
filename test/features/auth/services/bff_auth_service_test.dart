import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';

void main() {
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
  });
}
