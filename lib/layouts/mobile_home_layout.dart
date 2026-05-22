import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../widgets/home_widgets.dart';

class MobileHomeLayout extends StatelessWidget {
  const MobileHomeLayout({
    required this.questionController,
    required this.onSubmitQuestion,
    required this.onOpenAccount,
    required this.onOpenQuestionHistory,
    super.key,
  });

  final TextEditingController questionController;
  final VoidCallback onSubmitQuestion;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenQuestionHistory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MobileTopButton(
                label: '질문 목록',
                icon: Icons.menu_rounded,
                onTap: onOpenQuestionHistory,
              ),
              const Spacer(),
              _MobileTopButton(
                label: '계정 정보',
                icon: Icons.account_circle_rounded,
                onTap: onOpenAccount,
              ),
            ],
          ),
          const SizedBox(height: 44),
          Text(
            '마법의 소라고동!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: InteractiveConch(
                height: 220,
                onPull: onSubmitQuestion,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            '채팅 칠 수 있는 공간',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          QuestionInputPanel(
            controller: questionController,
            onSubmit: onSubmitQuestion,
          ),
        ],
      ),
    );
  }
}

class _MobileTopButton extends StatelessWidget {
  const _MobileTopButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primaryDark, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
