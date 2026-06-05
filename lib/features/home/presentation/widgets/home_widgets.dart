import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

const _historyRowText = AppTheme.textPrimary;
const _historyRowSecondary = AppTheme.textSecondary;
const _historyRow = Color(0xFFF2FBFA);
const _historyDivider = Color(0xFFCFE8E5);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  '최근 질문',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _historyRowText,
                    fontSize: 17,
                  ),
                ),
              ),
              Text(
                '${questions.length}개',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _historyRowSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return HistoryTile(question: questions[index]);
              },
            ),
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: _historyRow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _historyDivider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppTheme.primaryDark,
            size: 17,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              question,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _historyRowText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
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
  const ConchQuestionPanel({required this.onSubmit, super.key});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '마법의 소라고동!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppTheme.primaryDark,
            fontSize: 34,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        Flexible(
          child: Center(child: InteractiveConch(height: 390, onPull: onSubmit)),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Text(
            '질문을 쓰고 전송 버튼을 누르거나\n소라고동을 당겨보세요.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return OceanPanel(
          padding: EdgeInsets.all(isCompact ? 8 : 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 52,
                    maxHeight: 94,
                  ),
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSubmit(),
                    decoration: InputDecoration(
                      hintText: '무엇이 궁금한가요?',
                      prefixIcon: const Icon(Icons.edit_note_rounded, size: 22),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(2, 15, 16, 15),
                      filled: true,
                      fillColor: AppTheme.cream.withValues(alpha: 0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: AppTheme.border.withValues(alpha: 0.7),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: AppTheme.border.withValues(alpha: 0.7),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryTeal,
                          width: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox.square(
                dimension: isCompact ? 48 : 52,
                child: Material(
                  color: AppTheme.skyBlue,
                  shape: const CircleBorder(),
                  elevation: 0,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onSubmit,
                    child: Center(
                      child: Transform.translate(
                        offset: const Offset(1.5, 0),
                        child: const Icon(
                          Icons.send_rounded,
                          color: AppTheme.textPrimary,
                          size: 21,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class InteractiveConch extends StatefulWidget {
  const InteractiveConch({
    required this.height,
    required this.onPull,
    super.key,
  });

  final double height;
  final VoidCallback onPull;

  @override
  State<InteractiveConch> createState() => _InteractiveConchState();
}

class _InteractiveConchState extends State<InteractiveConch> {
  static const _imageAspectRatio = 1546 / 1017;
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
        final height = fittedHeight < widget.height
            ? fittedHeight
            : widget.height;
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
                    'assets/images/brand/magic_conch.png',
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
