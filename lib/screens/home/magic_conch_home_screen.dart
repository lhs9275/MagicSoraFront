import 'package:flutter/material.dart';

import '../../core/widgets/ocean_shell_widgets.dart';
import '../../layouts/desktop_home_layout.dart';
import '../../layouts/mobile_home_layout.dart';
import '../account/account_profile_screen.dart';
import 'magic_conch_result_screen.dart';
import 'question_history_screen.dart';

class MagicConchHomeScreen extends StatefulWidget {
  const MagicConchHomeScreen({super.key});

  @override
  State<MagicConchHomeScreen> createState() => _MagicConchHomeScreenState();
}

class _MagicConchHomeScreenState extends State<MagicConchHomeScreen> {
  final _questionController = TextEditingController();

  // TODO: 실제 질문 기록 데이터가 생기면 서버/로컬 저장소에서 불러오도록 교체한다.
  final List<String> _questionHistory = const [
    '오늘 토론 주제는 무엇이 좋을까?',
    'AI 의견을 어떻게 비교하면 좋을까?',
    '반박 근거를 더 탄탄하게 만들려면?',
    '최종 결론을 한 문장으로 정리해줘.',
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
      MaterialPageRoute<void>(builder: (_) => const AccountProfileScreen()),
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
