import 'package:flutter/material.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/account/presentation/screens/account_profile_screen.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';
import 'package:magicsorafront/features/home/presentation/layouts/desktop_home_layout.dart';
import 'package:magicsorafront/features/home/presentation/layouts/mobile_home_layout.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_result_screen.dart';
import 'package:magicsorafront/features/home/presentation/screens/question_history_screen.dart';
import 'package:magicsorafront/features/home/presentation/widgets/question_history_action_sheet.dart';

class MagicConchHomeScreen extends StatefulWidget {
  const MagicConchHomeScreen({super.key, this.user});

  final AppUser? user;

  @override
  State<MagicConchHomeScreen> createState() => _MagicConchHomeScreenState();
}

class _MagicConchHomeScreenState extends State<MagicConchHomeScreen> {
  static const List<String> _seedQuestions = [
    '나는 사람이다',
    '오늘 토론 주제는 무엇이 좋을까?',
    'AI 의견을 어떻게 비교하면 좋을까?',
    '반박 근거를 더 탄탄하게 만들려면?',
    '최종 결론을 한 문장으로 정리해줘.',
    '환경 보호 토론에서 핵심 근거는 뭐야?',
    '찬성 입장에서 설득력 있는 예시를 알려줘.',
    '반대 입장에서 가장 강한 논리는 뭐야?',
    '토론 시작 발언을 자연스럽게 만들어줘.',
    '상대방 질문에 짧게 답하는 방법은?',
    '논리적으로 보이게 말 순서를 정리해줘.',
    '근거가 부족한 문장을 고쳐줘.',
    '청중이 이해하기 쉬운 비유를 추천해줘.',
    '마지막 마무리 멘트를 만들어줘.',
    '내 주장에 어울리는 키워드를 뽑아줘.',
    '학교 급식 개선 토론 주제를 정리해줘.',
    '스마트폰 사용 제한 찬반 근거를 알려줘.',
    '동물 실험 반대 입장 근거를 만들어줘.',
    '발표할 때 긴장하지 않는 방법은?',
    '토론에서 질문을 날카롭게 만드는 법은?',
    '내 의견을 더 짧고 강하게 고쳐줘.',
    '자료 조사할 때 어떤 순서로 찾아야 해?',
    '상대방 주장에 예의 있게 반박하는 문장을 써줘.',
    '토론 카드에 넣을 핵심 문장을 추천해줘.',
    '오늘 질문 기록을 한눈에 정리해줘.',
  ];

  final _questionController = TextEditingController();
  final _debateApiService = DebateApiService();
  bool _isSubmittingQuestion = false;
  late AppUser _activeUser;
  AppUser get _currentUser => _activeUser;

  // TODO: 실제 질문 기록 데이터가 생기면 서버/로컬 저장소에서 불러오도록 교체한다.
  final List<QuestionHistoryEntry> _questionHistory = _buildQuestionHistory();

  static List<QuestionHistoryEntry> _buildQuestionHistory() {
    return [
      for (final question in _seedQuestions)
        QuestionHistoryEntry(
          question: question,
          answer: _buildMockHistoryAnswer(question),
        ),
    ];
  }

  static String _buildMockHistoryAnswer(String question) {
    if (question.contains('주제')) {
      return '생활과 연결되는 찬반형 주제가 좋습니다. 급식, 스마트폰 사용, 교복 자율화처럼 누구나 경험이 있는 주제를 고르면 입장 정리와 예시 확보가 쉬워집니다.';
    }

    if (question.contains('AI 의견')) {
      return '입장별 주장, 근거, 예상 반론을 같은 표에 놓고 비교하면 좋습니다. 기준을 3개 정도로 고정하면 어떤 의견이 더 설득력 있는지 빠르게 보입니다.';
    }

    if (question.contains('반박') ||
        question.contains('근거') ||
        question.contains('논리')) {
      return '주장을 먼저 한 문장으로 좁히고, 바로 뒤에 사실 근거와 예시를 붙이세요. 반박할 때는 상대 주장 한 부분만 집어서 왜 약한지 설명하면 훨씬 단단해집니다.';
    }

    if (question.contains('발표') ||
        question.contains('청중') ||
        question.contains('설득') ||
        question.contains('긴장')) {
      return '처음 10초 문장을 미리 외워두고, 문장을 짧게 끊어 말하는 것이 좋습니다. 청중이 따라오기 쉬운 예시 하나만 넣어도 전체 전달력이 안정됩니다.';
    }

    if (question.contains('자료') ||
        question.contains('조사') ||
        question.contains('예시')) {
      return '핵심 주장에 필요한 숫자, 사례, 출처를 따로 나눠 찾으세요. 먼저 신뢰 가능한 기사나 보고서로 큰 흐름을 잡고, 그 다음 구체 사례를 붙이는 순서가 안전합니다.';
    }

    if (question.contains('문장') ||
        question.contains('정리') ||
        question.contains('키워드') ||
        question.contains('마무리') ||
        question.contains('비유')) {
      return '한 문장에 하나의 메시지만 남기고 군더더기를 줄이면 훨씬 강해집니다. 마지막에는 주장과 이유를 한 번 더 묶어주는 짧은 문장이 가장 효과적입니다.';
    }

    return '이 질문은 다시 이어가기 좋은 기본 질문입니다. 핵심 입장을 먼저 세우고, 이유 두 가지와 짧은 예시 하나를 붙이면 바로 다음 답변으로 연결하기 좋습니다.';
  }

  @override
  void initState() {
    super.initState();
    _activeUser = widget.user ?? AppUser.fallback;
    _hydrateUser();
  }

  Future<void> _hydrateUser() async {
    final hydratedUser = await AuthSessionStore.instance.hydrateUser(
      _activeUser,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _activeUser = hydratedUser;
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _openResult() async {
    final trimmedQuestion = _questionController.text.trim();
    if (trimmedQuestion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('질문을 입력해주세요.')));
      return;
    }

    if (_isSubmittingQuestion) {
      return;
    }

    setState(() {
      _isSubmittingQuestion = true;
    });

    try {
      final debateId = await _debateApiService.startDebate(trimmedQuestion);
      if (!mounted) {
        return;
      }
      _openResultForQuestion(trimmedQuestion, debateId: debateId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '토론을 시작하지 못했습니다. 잠시 후 다시 시도해주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingQuestion = false;
        });
      }
    }
  }

  void _openResultForQuestion(String question, {int? debateId}) {
    final trimmedQuestion = question.trim();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MagicConchResultScreen(
          question: trimmedQuestion,
          debateId: debateId,
        ),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountProfileScreen(
          user: _currentUser,
          onUserChanged: (user) {
            if (!mounted) {
              return;
            }
            setState(() {
              _activeUser = user;
            });
          },
        ),
      ),
    );
  }

  void _openQuestionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestionHistoryScreen(
          questions: _questionHistory,
          loadFromApi: true,
          ownerNickname: _currentUser.nickname,
        ),
      ),
    );
  }

  void _openQuestionFromHistory(QuestionHistoryEntry entry) {
    showQuestionHistoryActionSheet(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return MobileHomeLayout(
                questionController: _questionController,
                onSubmitQuestion: _openResult,
                onOpenAccount: _openAccount,
                onOpenQuestionHistory: _openQuestionHistory,
              );
            }

            return DesktopHomeLayout(
              questions: _questionHistory,
              user: _currentUser,
              questionController: _questionController,
              onSubmitQuestion: _openResult,
              onOpenAccount: _openAccount,
              onOpenQuestionHistory: _openQuestionHistory,
              onOpenQuestionFromHistory: _openQuestionFromHistory,
            );
          },
        ),
      ),
    );
  }
}
