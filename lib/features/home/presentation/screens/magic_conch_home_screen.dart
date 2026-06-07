import 'package:flutter/material.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/account/presentation/screens/account_profile_screen.dart';
import 'package:magicsorafront/features/home/presentation/layouts/desktop_home_layout.dart';
import 'package:magicsorafront/features/home/presentation/layouts/mobile_home_layout.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_result_screen.dart';
import 'package:magicsorafront/features/home/presentation/screens/question_history_screen.dart';

class MagicConchHomeScreen extends StatefulWidget {
  const MagicConchHomeScreen({super.key, this.user});

  final AppUser? user;

  @override
  State<MagicConchHomeScreen> createState() => _MagicConchHomeScreenState();
}

class _MagicConchHomeScreenState extends State<MagicConchHomeScreen> {
  final _questionController = TextEditingController();
  AppUser get _currentUser => widget.user ?? AppUser.fallback;

  // TODO: 실제 질문 기록 데이터가 생기면 서버/로컬 저장소에서 불러오도록 교체한다.
  final List<String> _questionHistory = const [
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

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _openResult() {
    final question = _questionController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MagicConchResultScreen(question: question),
      ),
    );
  }

  void _openAccount() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AccountProfileScreen(user: _currentUser),
      ),
    );
  }

  void _openQuestionHistory() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => QuestionHistoryScreen(questions: _questionHistory),
      ),
    );
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
            );
          },
        ),
      ),
    );
  }
}
