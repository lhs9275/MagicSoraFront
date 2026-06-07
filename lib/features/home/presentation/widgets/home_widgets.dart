import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';

const _historyRowText = AppTheme.textPrimary;
const _historyRowSecondary = AppTheme.textSecondary;
const _historyDivider = Color(0xFFD6ECE8);

class QuestionHistoryPanel extends StatelessWidget {
  const QuestionHistoryPanel({
    required this.questions,
    super.key,
    this.onViewAll,
    this.onQuestionTap,
  });

  final List<QuestionHistoryEntry> questions;
  final VoidCallback? onViewAll;
  final ValueChanged<QuestionHistoryEntry>? onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '질문 아카이브',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _historyRowText,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '다시 꺼내보기 좋은 질문들',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _historyRowSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _HistoryCountPill(count: questions.length),
                  if (onViewAll != null) ...[
                    const SizedBox(height: 8),
                    _HistoryActionChip(onTap: onViewAll!),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                return HistoryTile(
                  question: questions[index].question,
                  index: index + 1,
                  compact: true,
                  onTap: onQuestionTap == null
                      ? null
                      : () => onQuestionTap!(questions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTile extends StatelessWidget {
  const HistoryTile({
    required this.question,
    super.key,
    this.index,
    this.compact = false,
    this.caption,
    this.backgroundColor,
    this.borderColor,
    this.trailing,
    this.onTap,
  });

  final String question;
  final int? index;
  final bool compact;
  final String? caption;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final questionStyle =
        (compact
                ? Theme.of(context).textTheme.bodyMedium
                : Theme.of(context).textTheme.bodyLarge)
            ?.copyWith(
              color: _historyRowText,
              fontWeight: FontWeight.w800,
              height: compact ? 1.42 : 1.5,
            );
    final captionStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: _historyRowSecondary,
      fontSize: compact ? 12 : 13,
      fontWeight: FontWeight.w700,
      height: 1.35,
    );
    final badgeSize = compact ? 36.0 : 44.0;
    final radius = compact ? 20.0 : 24.0;
    final decoration = BoxDecoration(
      color: backgroundColor ?? Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? _historyDivider.withValues(alpha: 0.9),
      ),
      boxShadow: compact
          ? null
          : [
              BoxShadow(
                color: AppTheme.shadowTint.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
    );
    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 14,
        compact ? 12 : 14,
        compact ? 12 : 16,
        compact ? 12 : 14,
      ),
      child: Row(
        crossAxisAlignment: caption == null
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Container(
            width: badgeSize,
            height: badgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(compact ? 14 : 16),
              border: Border.all(
                color: AppTheme.skyBlue.withValues(alpha: 0.22),
              ),
            ),
            child: index == null
                ? Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppTheme.primaryDark,
                    size: compact ? 17 : 18,
                  )
                : Text(
                    index!.toString().padLeft(2, '0'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryDark,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: caption == null
                  ? Alignment.centerLeft
                  : Alignment.topLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (caption != null) ...[
                    Text(caption!, style: captionStyle),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    question,
                    maxLines: compact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: questionStyle,
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );

    if (onTap == null) {
      return Container(
        width: double.infinity,
        decoration: decoration,
        child: content,
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          decoration: decoration,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}

class _HistoryCountPill extends StatelessWidget {
  const _HistoryCountPill({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.22)),
      ),
      child: Text(
        '$count개',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: _historyRowSecondary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _HistoryActionChip extends StatelessWidget {
  const _HistoryActionChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppTheme.surfaceRaised.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '전체 보기',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppTheme.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountShortcut extends StatelessWidget {
  const AccountShortcut({required this.onTap, super.key, AppUser? user})
    : user = user ?? AppUser.fallback;

  final AppUser user;
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
                      user.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          color: Colors.white.withValues(alpha: 0.86),
          borderColor: AppTheme.skyBlue.withValues(alpha: 0.5),
          radius: 30,
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
                      fillColor: Colors.white.withValues(alpha: 0.94),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: AppTheme.skyBlue.withValues(alpha: 0.28),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: AppTheme.skyBlue.withValues(alpha: 0.28),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryTeal,
                          width: 1.8,
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
