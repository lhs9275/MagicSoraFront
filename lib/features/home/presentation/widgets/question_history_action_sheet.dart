import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_result_screen.dart';

Future<void> showQuestionHistoryActionSheet(
  BuildContext context,
  QuestionHistoryEntry entry, {
  DebateApiService? debateApiService,
  Future<void> Function(QuestionHistoryEntry entry)? onDelete,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      Future<void> continueQuestion() async {
        await Navigator.of(sheetContext).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => MagicConchResultScreen(
              question: entry.question,
              initialAnswer: entry.answer,
              debateId: entry.debateId,
              showAnswerImmediately: true,
              showFollowUpInputInitially: true,
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
        debateApiService: debateApiService,
        onContinueQuestion: continueQuestion,
        onDelete: onDelete == null ? null : deleteEntry,
      );
    },
  );
}

class _QuestionHistoryActionSheet extends StatefulWidget {
  const _QuestionHistoryActionSheet({
    required this.entry,
    required this.onContinueQuestion,
    this.debateApiService,
    this.onDelete,
  });

  final QuestionHistoryEntry entry;
  final DebateApiService? debateApiService;
  final VoidCallback onContinueQuestion;
  final VoidCallback? onDelete;

  @override
  State<_QuestionHistoryActionSheet> createState() =>
      _QuestionHistoryActionSheetState();
}

class _QuestionHistoryActionSheetState
    extends State<_QuestionHistoryActionSheet> {
  int? _followUpCount;
  bool _isLoadingFollowUps = false;
  bool _hasFollowUpError = false;

  @override
  void initState() {
    super.initState();
    final debateId = widget.entry.debateId;
    final service = widget.debateApiService;
    if (debateId != null && service != null) {
      _isLoadingFollowUps = true;
      _loadFollowUpCount(service, debateId);
    }
  }

  Future<void> _loadFollowUpCount(
    DebateApiService service,
    int debateId,
  ) async {
    try {
      final history = await service.fetchQuestions(debateId);
      if (!mounted) return;
      setState(() {
        _followUpCount = history.length;
        _isLoadingFollowUps = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasFollowUpError = true;
        _isLoadingFollowUps = false;
      });
    }
  }

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
                widget.entry.question,
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
                      widget.entry.answer,
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
              _FollowUpCountChip(
                isLoading: _isLoadingFollowUps,
                hasError: _hasFollowUpError,
                count: _followUpCount,
              ),
              OceanPillButton(
                label: '이어서 질문하기',
                icon: Icons.forum_rounded,
                backgroundColor: AppTheme.primaryLight,
                onPressed: widget.onContinueQuestion,
              ),
              if (widget.onDelete != null) ...[
                const SizedBox(height: 10),
                OceanPillButton(
                  label: '기록 삭제',
                  icon: Icons.delete_rounded,
                  backgroundColor: AppTheme.coral,
                  onPressed: widget.onDelete!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpCountChip extends StatelessWidget {
  const _FollowUpCountChip({
    required this.isLoading,
    required this.hasError,
    required this.count,
  });

  final bool isLoading;
  final bool hasError;
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (!isLoading && hasError) return const SizedBox(height: 18);
    if (!isLoading && count == null) return const SizedBox(height: 18);

    final theme = Theme.of(context);
    final Widget content;
    if (isLoading) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '추가 질문 확인 중…',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    } else {
      final n = count ?? 0;
      final label = n == 0 ? '아직 추가 질문이 없습니다' : '지금까지 추가 질문 $n개';
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            n == 0 ? Icons.forum_outlined : Icons.forum_rounded,
            size: 16,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppTheme.primaryTeal.withValues(alpha: 0.18),
          ),
        ),
        child: content,
      ),
    );
  }
}
