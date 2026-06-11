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

    test('SSE 연결이 401이면 같은 토큰으로 재시도하지 않는다', () async {
      await saveSession();
      var streamAttempt = 0;
      var refreshAttempt = 0;

      final service = DebateApiService(
        streamRetryDelays: const [Duration.zero],
        httpClient: MockClient.streaming((request, bodyStream) async {
          if (request.url.path == '/mapi/auth/refresh') {
            refreshAttempt += 1;
            return http.StreamedResponse(
              Stream<List<int>>.fromIterable([utf8.encode('')]),
              401,
            );
          }
          streamAttempt += 1;
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
      // 스트림 자체는 같은 토큰으로 재요청하지 않고, refresh 한 번만 시도하고 그만둔다.
      expect(streamAttempt, 1);
      expect(refreshAttempt, 1);
    });

    test('추가 질문 SSE delta와 answer_completed를 파싱한다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient.streaming((request, bodyStream) async {
          expect(request.method, 'POST');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/api/debates/42/questions'),
          );
          expect(request.headers['Authorization'], 'Bearer bff-access');
          expect(
            request.headers['Accept'],
            'text/event-stream',
          );
          expect(
            request.headers['Content-Type'],
            contains('application/json'),
          );

          final bodyBytes = await bodyStream
              .fold<List<int>>(<int>[], (acc, chunk) => acc..addAll(chunk));
          expect(jsonDecode(utf8.decode(bodyBytes)), {
            'question': '반대 측의 핵심 논거는 무엇이었나?',
          });

          return http.StreamedResponse(
            Stream<List<int>>.fromIterable([
              utf8.encode('event: delta\n'),
              utf8.encode('data: {"text":"반대"}\n\n'),
              utf8.encode('event: delta\n'),
              utf8.encode('data: {"text":" 측의"}\n\n'),
              utf8.encode('event: answer_completed\n'),
              utf8.encode(
                'data: {"questionId":3,"answer":"반대 측의 핵심 논거..."}\n\n',
              ),
            ]),
            200,
            headers: {'Content-Type': 'text/event-stream'},
          );
        }),
      );

      final events = await service
          .askQuestion(42, '반대 측의 핵심 논거는 무엇이었나?')
          .toList();

      expect(events, hasLength(3));
      expect(events[0].isDelta, isTrue);
      expect(events[0].deltaText, '반대');
      expect(events[1].deltaText, ' 측의');
      expect(events[2].isAnswerCompleted, isTrue);
      expect(events[2].questionId, 3);
      expect(events[2].answerText, '반대 측의 핵심 논거...');
    });

    test('추가 질문이 409면 본문 메시지로 예외를 던진다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient.streaming((request, bodyStream) async {
          return http.StreamedResponse(
            Stream<List<int>>.fromIterable([
              utf8.encode('{"message":"debate not finished"}'),
            ]),
            409,
            headers: {'Content-Type': 'application/json'},
          );
        }),
      );

      await expectLater(
        service.askQuestion(42, '추가 질문').toList(),
        throwsA(
          isA<DebateApiException>()
              .having((error) => error.statusCode, 'statusCode', 409)
              .having(
                (error) => error.message,
                'message',
                'debate not finished',
              ),
        ),
      );
    });

    test('추가 질문 이력 GET 응답을 매핑한다', () async {
      await saveSession();

      final service = DebateApiService(
        httpClient: MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url,
            Uri.parse('https://bff.noctide.dev/api/debates/42/questions'),
          );
          expect(request.headers['Authorization'], 'Bearer bff-access');

          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {
                  'id': 1,
                  'question': '첫 추가 질문',
                  'answer': '첫 답변',
                  'createdAt': '2026-06-11T17:20:00',
                },
                {
                  'id': 2,
                  'question': '두번째 추가 질문',
                  'answer': '두번째 답변',
                  'createdAt': '2026-06-11T17:22:20',
                },
              ]),
            ),
            200,
            headers: {'Content-Type': 'application/json; charset=utf-8'},
          );
        }),
      );

      final history = await service.fetchQuestions(42);

      expect(history, hasLength(2));
      expect(history.first.id, 1);
      expect(history.first.question, '첫 추가 질문');
      expect(history.last.answer, '두번째 답변');
      // 가이드: 모든 시각은 서버(UTC) 기준 ISO-8601. naive 문자열은 UTC로 해석한다.
      expect(
        history.last.createdAt,
        DateTime.parse('2026-06-11T17:22:20Z'),
      );
    });

    test('401을 받으면 refresh 후 동일 요청을 재시도한다', () async {
      await saveSession();
      var startAttempt = 0;
      var refreshCalled = false;

      final httpClient = MockClient((request) async {
        if (request.url.path == '/mapi/auth/refresh') {
          refreshCalled = true;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {'refresh_token': 'bff-refresh'});
          return http.Response(
            jsonEncode({
              'access_token': 'rotated-access',
              'refresh_token': 'rotated-refresh',
              'token_type': 'Bearer',
            }),
            200,
            headers: {'Content-Type': 'application/json'},
          );
        }

        if (request.url.path == '/api/debates' && request.method == 'POST') {
          startAttempt += 1;
          if (startAttempt == 1) {
            expect(request.headers['Authorization'], 'Bearer bff-access');
            return http.Response(
              jsonEncode({'message': 'token expired'}),
              401,
              headers: {'Content-Type': 'application/json'},
            );
          }
          expect(request.headers['Authorization'], 'Bearer rotated-access');
          return http.Response(
            jsonEncode({'debateId': 99}),
            202,
            headers: {'Content-Type': 'application/json'},
          );
        }

        fail('unexpected request to ${request.url}');
      });

      final service = DebateApiService(httpClient: httpClient);

      expect(await service.startDebate('AI'), 99);
      expect(refreshCalled, isTrue);
      expect(startAttempt, 2);
    });

    test('refresh가 실패하면 401을 그대로 던지고 재시도하지 않는다', () async {
      await saveSession();
      var startAttempt = 0;
      var refreshAttempt = 0;

      final httpClient = MockClient((request) async {
        if (request.url.path == '/mapi/auth/refresh') {
          refreshAttempt += 1;
          return http.Response('', 401);
        }
        startAttempt += 1;
        return http.Response(
          jsonEncode({'message': 'expired'}),
          401,
          headers: {'Content-Type': 'application/json'},
        );
      });

      final service = DebateApiService(httpClient: httpClient);

      await expectLater(
        service.startDebate('AI'),
        throwsA(
          isA<DebateApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      expect(startAttempt, 1);
      expect(refreshAttempt, 1);
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
