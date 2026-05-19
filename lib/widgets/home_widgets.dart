import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/ocean_shell_widgets.dart';

class QuestionHistoryPanel extends StatelessWidget {
  const QuestionHistoryPanel({required this.questions, super.key});

  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내가 여태까지 질문했던 목록들',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          for (final question in questions) ...[
            HistoryTile(question: question),
            if (question != questions.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({required this.question, super.key});

  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cream.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        question,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AccountShortcut extends StatelessWidget {
  const AccountShortcut({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: OceanPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.account_circle_rounded,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '내 계정 상세정보',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sora Demo',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConchQuestionPanel extends StatelessWidget {
  const ConchQuestionPanel({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  '마법의 소라고동!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.primaryDark,
                    fontSize: 34,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 280,
              child: Text(
                '사용법 : 질문을 작성하고 ENTER 또는 줄을 당겨주세요!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 5,
              child: InteractiveConch(height: 390, onPull: onSubmit),
            ),
            const SizedBox(width: 18),
            SizedBox(
              width: 260,
              child: Text(
                '소라고동에 달린 고리를 오른쪽으로 잡아당기면 다음 창으로 넘어갑니다.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        QuestionInputPanel(controller: controller, onSubmit: onSubmit),
      ],
    );
  }
}

class QuestionInputPanel extends StatelessWidget {
  const QuestionInputPanel({
    required this.controller,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              hintText: '사용자가 질문을 입력할 공간',
              prefixIcon: Icon(Icons.edit_note_rounded),
              contentPadding: EdgeInsets.fromLTRB(18, 16, 132, 76),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: SizedBox(
              width: 116,
              child: OceanPillButton(
                label: 'ENTER',
                backgroundColor: AppTheme.shellPink,
                onPressed: onSubmit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InteractiveConch extends StatefulWidget {
  const InteractiveConch({required this.height, required this.onPull, super.key});

  final double height;
  final VoidCallback onPull;

  @override
  State<InteractiveConch> createState() => _InteractiveConchState();
}

class _InteractiveConchState extends State<InteractiveConch> {
  static const _imageAspectRatio = 956 / 694;
  static const _pullThreshold = 54.0;
  static const _maxPullDistance = 92.0;

  double _pullDistance = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _pullDistance = (_pullDistance + details.delta.dx)
          .clamp(0.0, _maxPullDistance)
          .toDouble();
    });
  }

  void _handleDragEnd() {
    final shouldOpenResult = _pullDistance >= _pullThreshold;

    setState(() {
      _pullDistance = 0;
    });

    if (shouldOpenResult) {
      widget.onPull();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.height * _imageAspectRatio + _maxPullDistance;
        final fittedHeight = (maxWidth - _maxPullDistance) / _imageAspectRatio;
        final height = fittedHeight < widget.height ? fittedHeight : widget.height;
        final width = height * _imageAspectRatio;
        final ringSize = height < 340 ? 54.0 : 66.0;

        return Semantics(
          button: true,
          label: '소라고동 줄을 오른쪽으로 당겨 질문하기',
          child: SizedBox(
            width: width + _maxPullDistance,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: width,
                  height: height,
                  child: Image.asset(
                    'assets/images/magic_conch.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: width * 0.82,
                  top: height * 0.49,
                  width: width * 0.2 + _maxPullDistance,
                  height: height * 0.18,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(_pullDistance, 0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: _handleDragUpdate,
                          onHorizontalDragEnd: (_) => _handleDragEnd(),
                          onHorizontalDragCancel: _handleDragEnd,
                          child: Container(
                            width: ringSize,
                            height: ringSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryDark,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryDark.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.radio_button_checked_rounded,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
