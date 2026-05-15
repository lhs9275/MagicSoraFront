import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';

class MagicConchResultScreen extends StatelessWidget {
  const MagicConchResultScreen({required this.question, super.key});

  final String question;

  @override
  Widget build(BuildContext context) {
    final displayQuestion = question.isEmpty ? '질문이 아직 비어 있어요.' : question;
    // TODO: 실제 답변 생성 API가 준비되면 질문을 전달하고 결과 문구를 교체한다.

    return Scaffold(
      appBar: AppBar(title: const Text('소라고동의 답변')),
      body: OceanShellBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: OceanPanel(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/magic_conch.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Text('질문', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      displayQuestion,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 22),
                    Text(
                      '마법의 소라고동이 곧 답을 들려줄 거예요.',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.primaryDark,
                            fontSize: 24,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OceanPillButton(
                      label: '다시 질문하기',
                      icon: Icons.keyboard_return_rounded,
                      backgroundColor: AppTheme.shellPurple,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
