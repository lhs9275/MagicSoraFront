import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_result_screen.dart';

Future<void> showQuestionHistoryActionSheet(
  BuildContext context,
  QuestionHistoryEntry entry, {
  Future<void> Function(QuestionHistoryEntry entry)? onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      Future<void> openHistoryRoute({
        required bool showFollowUpInputInitially,
      }) async {
        await Navigator.of(sheetContext).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MagicConchResultScreen(
              question: entry.question,
              initialAnswer: entry.answer,
              showAnswerImmediately: true,
              showFollowUpInputInitially: showFollowUpInputInitially,
            ),
          ),
        );
      }

      Future<void> deleteEntry() async {
        await Navigator.of(sheetContext).maybePop();
        await onDelete?.call(entry);
      }

      return _QuestionHistoryActionSheet(
        entry: entry,
        onViewPreviousAnswer: () =>
            openHistoryRoute(showFollowUpInputInitially: false),
        onContinueQuestion: () =>
            openHistoryRoute(showFollowUpInputInitially: true),
        onDelete: onDelete == null ? null : deleteEntry,
      );
    },
  );
}

class _QuestionHistoryActionSheet extends StatelessWidget {
  const _QuestionHistoryActionSheet({
    required this.entry,
    required this.onViewPreviousAnswer,
    required this.onContinueQuestion,
    this.onDelete,
  });

  final QuestionHistoryEntry entry;
  final VoidCallback onViewPreviousAnswer;
  final VoidCallback onContinueQuestion;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: OceanPanel(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          color: Colors.white.withValues(alpha: 0.94),
          borderColor: AppTheme.skyBlue.withValues(alpha: 0.28),
          radius: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.borderStrong.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '저장된 질문',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.question,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceMuted.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.skyBlue.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이전에 받은 답변 미리보기',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.answer,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OceanPillButton(
                label: '이전 답변 보기',
                icon: Icons.visibility_rounded,
                backgroundColor: AppTheme.primaryLight,
                onPressed: onViewPreviousAnswer,
              ),
              const SizedBox(height: 10),
              OceanPillButton(
                label: '이어서 질문하기',
                icon: Icons.forum_rounded,
                backgroundColor: const Color(0xFFE2D3FF),
                onPressed: onContinueQuestion,
              ),
              if (onDelete != null) ...[
                const SizedBox(height: 10),
                OceanPillButton(
                  label: '기록 삭제',
                  icon: Icons.delete_rounded,
                  backgroundColor: AppTheme.coral,
                  onPressed: onDelete!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
