import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> saveSession() {
    return AuthSessionStore.instance.saveSession(
      const AuthSession(
        accessToken: 'bff-access',
        refreshToken: 'bff-refresh',
        user: AppUser(
          nickname: 'tester',
          loginProvider: '카카오',
          email: 'tester@example.com',
        ),
      ),
    );
  }

  group('DebateApiService', () {
    test('토론 생성 요청에 Bearer 토큰과 topic을 보낸다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url, Uri.parse('https://bff.noctide.dev/api/debates'));
          expect(request.headers['Authorization'], 'Bearer bff-access');
          expect(request.headers['Content-Type'], 'application/json');
          expect(jsonDecode(request.body), {'topic': 'AI 토론'});

          return http.Response(
            jsonEncode({'debateId': 42}),
            202,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      await expectLater(service.startDebate('AI 토론'), completion(42));
    });

    test('SSE 스트림을 이벤트 단위로 파싱한다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient.streaming((request, bodyStream) async {
          expect(request.method, 'GET');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/api/debates/42/stream'),
          );
          expect(request.headers['Authorization'], 'Bearer bff-access');
          expect(request.headers['Accept'], 'text/event-stream');

          final chunks = Stream<List<int>>.fromIterable([
            utf8.encode('event: stage_started\n'),
            utf8.encode('data: {"role":"pro"}\n\n'),
            utf8.encode(
              'event: final\ndata: {"verdict":"PRO","status":"ok"}\n\n',
            ),
          ]);

          return http.StreamedResponse(
            chunks,
            200,
            headers: {'Content-Type': 'text/event-stream'},
          );
        }),
      );

      final events = await service.streamDebate(42).toList();

      expect(events, hasLength(2));
      expect(events.first.event, 'stage_started');
      expect(events.first.payload['role'], 'pro');
      expect(events.last.isFinal, isTrue);
      expect(events.last.verdict, 'PRO');
      expect(events.last.engineStatus, 'ok');
    });

    test('SSE 연결이 500이면 재시도 후 성공할 수 있다', () async {
      await saveSession();
      var attemptCount = 0;

      final service = DebateApiService(
        streamRetryDelays: const [Duration.zero],
        httpClient: MockClient.streaming((request, bodyStream) async {
          attemptCount += 1;

          if (attemptCount == 1) {
            return http.StreamedResponse(
              Stream<List<int>>.fromIterable([
                utf8.encode('{"message":"temporary failure"}'),
              ]),
              500,
              headers: {'Content-Type': 'application/json'},
            );
          }

          return http.StreamedResponse(
            Stream<List<int>>.fromIterable([
              utf8.encode('event: final\n'),
              utf8.encode('data: {"verdict":"PRO","status":"ok"}\n\n'),
            ]),
            200,
            headers: {'Content-Type': 'text/event-stream'},
          );
        }),
      );

      final events = await service.streamDebate(42).toList();

      expect(attemptCount, 2);
      expect(events.single.isFinal, isTrue);
      expect(events.single.verdict, 'PRO');
    });

    test('SSE 연결이 401이면 재시도하지 않는다', () async {
      await saveSession();
      var attemptCount = 0;

      final service = DebateApiService(
        streamRetryDelays: const [Duration.zero],
        httpClient: MockClient.streaming((request, bodyStream) async {
          attemptCount += 1;
          return http.StreamedResponse(
            Stream<List<int>>.fromIterable([
              utf8.encode('{"message":"unauthorized"}'),
            ]),
            401,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.streamDebate(42).toList(),
        throwsA(
          isA<DebateApiException>()
              .having((error) => error.statusCode, 'statusCode', 401)
              .having((error) => error.message, 'message', 'unauthorized'),
        ),
      );
      expect(attemptCount, 1);
    });

    test('토론 목록에서 finalVerdict와 커서를 매핑한다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/api/debates?cursor=40'),
          );
          expect(request.headers['Authorization'], 'Bearer bff-access');

          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'items': [
                  {
                    'id': 42,
                    'topic': 'AI 토론',
                    'status': 'DONE',
                    'finalVerdict': 'PRO 우세',
                    'totalScore': 7.5,
                    'createdAt': '2026-06-06T16:30:00',
                  },
                ],
                'nextCursor': 21,
                'hasNext': true,
              }),
            ),
            200,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final page = await service.fetchDebates(cursor: 40);

      expect(page.hasNext, isTrue);
      expect(page.nextCursor, 21);
      expect(page.items.single.status, DebateStatus.done);
      expect(page.items.single.finalVerdict, 'PRO 우세');
      expect(page.items.single.totalScore, 7.5);
    });
  });
}
