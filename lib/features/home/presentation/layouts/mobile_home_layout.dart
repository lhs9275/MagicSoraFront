import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/features/home/presentation/widgets/home_widgets.dart';

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
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
        final inputBottom = keyboardBottom > 0 ? keyboardBottom + 12 : 16.0;
        final contentBottomPadding = inputBottom + 100;
        final isShort = constraints.maxHeight < 620;
        final conchHeight = isShort ? 220.0 : 270.0;
        final conchMaxWidth = constraints.maxWidth < 360 ? 320.0 : 380.0;
        const conchScale = 1.25;

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, contentBottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _MobileTopButton(
                          label: '질문 기록',
                          icon: Icons.history_rounded,
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
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '마법의 소라고동!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppTheme.primaryDark,
                                      fontSize: constraints.maxHeight < 620
                                          ? 30
                                          : 34,
                                      height: 1.08,
                                    ),
                              ),
                              const SizedBox(height: 20),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: conchMaxWidth,
                                ),
                                child: SizedBox(
                                  height: conchHeight * conchScale,
                                  child: Center(
                                    child: Transform.translate(
                                      offset: const Offset(-6, 0),
                                      child: Transform.scale(
                                        scale: conchScale,
                                        child: InteractiveConch(
                                          height: conchHeight,
                                          centerOnShell: true,
                                          tiltAngle: 0.22,
                                          onPull: onSubmitQuestion,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '질문을 쓰고 전송 버튼을 누르거나\n소라고동을 당겨보세요.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontSize: 20, height: 1.36),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              left: 16,
              right: 16,
              bottom: inputBottom,
              child: QuestionInputPanel(
                controller: questionController,
                onSubmit: onSubmitQuestion,
              ),
            ),
          ],
        );
      },
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
