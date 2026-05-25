import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/home/presentation/widgets/home_widgets.dart';

class QuestionHistoryScreen extends StatelessWidget {
  const QuestionHistoryScreen({required this.questions, super.key});

  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: QuestionHistoryPanel(questions: questions),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: SizedBox(
                width: 190,
                child: OceanPillButton(
                  label: '채팅으로 돌아가기',
                  icon: Icons.chat_bubble_rounded,
                  backgroundColor: AppTheme.shellPurple,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
