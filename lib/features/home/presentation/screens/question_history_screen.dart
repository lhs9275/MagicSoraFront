import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_snack_bar.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';
import 'package:magicsorafront/features/home/presentation/widgets/home_widgets.dart';
import 'package:magicsorafront/features/home/presentation/widgets/question_history_archive_widgets.dart';
import 'package:magicsorafront/features/home/presentation/widgets/question_history_action_sheet.dart';

class QuestionHistoryScreen extends StatefulWidget {
  const QuestionHistoryScreen({
    required this.questions,
    super.key,
    this.loadFromApi = false,
    this.debateApiService,
    this.ownerNickname,
  });

  final List<QuestionHistoryEntry> questions;
  final bool loadFromApi;
  final DebateApiService? debateApiService;
  final String? ownerNickname;

  @override
  State<QuestionHistoryScreen> createState() => _QuestionHistoryScreenState();
}

class _QuestionHistoryScreenState extends State<QuestionHistoryScreen> {
  final _searchController = TextEditingController();
  late final DebateApiService _debateApiService;

  String _keyword = '';
  List<QuestionHistoryEntry>? _remoteQuestions;
  final Set<String> _favoriteQuestionKeys = <String>{};
  final Set<int> _selectedDebateIds = <int>{};
  QuestionHistorySortMode _sortMode = QuestionHistorySortMode.date;
  bool _isSortAscending = false;
  bool _isLoading = false;
  bool _isDeletingBulk = false;
  String? _loadErrorMessage;

  List<QuestionHistoryEntry> get _questions {
    if (widget.loadFromApi) {
      return _remoteQuestions ?? const <QuestionHistoryEntry>[];
    }
    return _remoteQuestions ?? widget.questions;
  }

  List<_QuestionArchiveEntry> get _filteredQuestions {
    final rawKeyword = _keyword.trim().toLowerCase();
    final keyword = _compactSearchText(rawKeyword);
    final keywordInitials = _toHangulInitials(keyword);
    final entries = [
      for (var index = 0; index < _questions.length; index++)
        _QuestionArchiveEntry(number: index + 1, entry: _questions[index]),
    ];

    final filteredEntries = keyword.isEmpty
        ? entries
        : entries.where((entry) {
            final rawQuestion = entry.question.toLowerCase();
            final questionText = _compactSearchText(rawQuestion);
            final questionInitials = _toHangulInitials(questionText);
            final questionWordInitials = _toHangulWordInitials(rawQuestion);

            return questionText.contains(keyword) ||
                questionInitials.contains(keyword) ||
                questionInitials.contains(keywordInitials) ||
                questionWordInitials.contains(keyword) ||
                questionWordInitials.contains(keywordInitials);
          }).toList();

    return _sortEntries(filteredEntries);
  }

  int get _favoriteCount => _questions.where(_isFavorite).length;
  List<QuestionHistoryEntry> get _deletableQuestions => [
    for (final question in _questions)
      if (question.debateId != null) question,
  ];
  List<QuestionHistoryEntry> get _selectedDeletableQuestions => [
    for (final question in _deletableQuestions)
      if (_isSelected(question)) question,
  ];
  int get _selectedDebateCount => _selectedDeletableQuestions.length;

  List<_QuestionArchiveEntry> _sortEntries(
    List<_QuestionArchiveEntry> entries,
  ) {
    final sortedEntries = [...entries];

    // 원본 데이터는 수정하지 않고 화면 표시용 리스트만 정렬한다.
    switch (_sortMode) {
      case QuestionHistorySortMode.date:
        sortedEntries.sort(_compareByDate);
      case QuestionHistorySortMode.favorite:
        sortedEntries.sort((a, b) {
          final aFavorite = _isFavorite(a.entry);
          final bFavorite = _isFavorite(b.entry);
          if (aFavorite != bFavorite) {
            return bFavorite ? 1 : -1;
          }
          return _compareByDate(a, b);
        });
      case QuestionHistorySortMode.text:
        sortedEntries.sort((a, b) {
          final compared = a.question.compareTo(b.question);
          if (compared != 0) {
            return _isSortAscending ? compared : -compared;
          }
          return a.number.compareTo(b.number);
        });
    }

    return sortedEntries;
  }

  int _compareByDate(_QuestionArchiveEntry a, _QuestionArchiveEntry b) {
    final aDate = a.entry.createdAt;
    final bDate = b.entry.createdAt;
    final fallbackCompare = a.number.compareTo(b.number);

    if (aDate != null && bDate != null) {
      final compared = aDate.compareTo(bDate);
      return _isSortAscending ? compared : -compared;
    }
    if (aDate != null) {
      return _isSortAscending ? 1 : -1;
    }
    if (bDate != null) {
      return _isSortAscending ? -1 : 1;
    }
    return _isSortAscending ? -fallbackCompare : fallbackCompare;
  }

  String _compactSearchText(String value) {
    return value.replaceAll(RegExp(r'\s+'), '');
  }

  String _toHangulInitials(String value) {
    const initials = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ',
    ];

    final buffer = StringBuffer();

    for (final rune in value.runes) {
      if (rune >= 0xAC00 && rune <= 0xD7A3) {
        final initialIndex = (rune - 0xAC00) ~/ 588;
        buffer.write(initials[initialIndex]);
      } else {
        buffer.write(String.fromCharCode(rune));
      }
    }

    return buffer.toString();
  }

  String _toHangulWordInitials(String value) {
    final words = value.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final buffer = StringBuffer();

    for (final word in words) {
      buffer.write(_toHangulInitials(String.fromCharCode(word.runes.first)));
    }

    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _debateApiService = widget.debateApiService ?? DebateApiService();
    if (widget.loadFromApi) {
      _loadDebates();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _keyword = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _handleSearchChanged('');
  }

  void _handleSortChanged(QuestionHistorySortMode mode) {
    setState(() {
      _sortMode = mode;
      _isSortAscending = false;
    });
  }

  String _favoriteKeyFor(QuestionHistoryEntry entry) {
    final debateId = entry.debateId;
    if (debateId != null) {
      return 'debate:$debateId';
    }
    return 'local:${entry.question}::${entry.answer}';
  }

  bool _isFavorite(QuestionHistoryEntry entry) {
    return _favoriteQuestionKeys.contains(_favoriteKeyFor(entry));
  }

  void _toggleFavorite(QuestionHistoryEntry entry) {
    if (_isDeletingBulk) {
      return;
    }

    final key = _favoriteKeyFor(entry);
    setState(() {
      if (!_favoriteQuestionKeys.remove(key)) {
        _favoriteQuestionKeys.add(key);
      }
    });
  }

  void _openQuestionActions(QuestionHistoryEntry entry) {
    showQuestionHistoryActionSheet(
      context,
      entry,
      debateApiService: _debateApiService,
      onDelete: entry.debateId == null ? null : _confirmDeleteDebate,
    );
  }

  Future<void> _loadDebates() async {
    setState(() {
      _isLoading = true;
      _loadErrorMessage = null;
    });

    try {
      final page = await _debateApiService.fetchDebates();
      if (!mounted) {
        return;
      }
      setState(() {
        _remoteQuestions = page.items
            .map(_entryFromDebateSummary)
            .whereType<QuestionHistoryEntry>()
            .toList();
        _selectedDebateIds.clear();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '질문 기록을 불러오지 못했습니다.';
      setState(() {
        _isLoading = false;
        _loadErrorMessage = message;
      });
    }
  }

  QuestionHistoryEntry? _entryFromDebateSummary(DebateSummary summary) {
    final answer = summary.finalVerdict?.trim() ?? '';
    if (answer.isEmpty) {
      return null;
    }

    return QuestionHistoryEntry(
      question: summary.topic,
      answer: answer,
      debateId: summary.id,
      status: summary.status,
      createdAt: summary.createdAt,
    );
  }

  Future<void> _confirmDeleteDebate(QuestionHistoryEntry entry) async {
    if (_isDeletingBulk) {
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('질문 기록 삭제'),
          content: Text('이 질문 기록을 삭제하시겠어요?\n\n${entry.question}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteDebate(entry);
  }

  bool _isSelected(QuestionHistoryEntry entry) {
    final debateId = entry.debateId;
    return debateId != null && _selectedDebateIds.contains(debateId);
  }

  void _toggleDebateSelection(QuestionHistoryEntry entry, bool? value) {
    final debateId = entry.debateId;
    if (debateId == null || _isDeletingBulk) {
      return;
    }

    setState(() {
      if (value == true) {
        _selectedDebateIds.add(debateId);
      } else {
        _selectedDebateIds.remove(debateId);
      }
    });
  }

  Future<void> _confirmDeleteSelectedDebates() async {
    if (_isDeletingBulk || _selectedDeletableQuestions.isEmpty) {
      return;
    }

    final selectedCount = _selectedDeletableQuestions.length;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('선택한 질문 기록 삭제'),
          content: Text('선택한 질문 기록 $selectedCount개를 삭제하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteSelectedDebates();
  }

  Future<void> _confirmDeleteAllDebates() async {
    if (_isDeletingBulk || _deletableQuestions.isEmpty) {
      return;
    }

    final deletableCount = _deletableQuestions.length;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('전체 질문 기록 삭제'),
          content: Text('삭제 가능한 질문 기록 $deletableCount개를 모두 삭제하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
              child: const Text('전체 삭제'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteAllDebates();
  }

  Future<void> _deleteDebate(QuestionHistoryEntry entry) async {
    final debateId = entry.debateId;
    if (debateId == null) {
      return;
    }

    try {
      await _debateApiService.deleteDebate(debateId);
      if (!mounted) {
        return;
      }
      setState(() {
        _removeDeletedDebateIds({debateId});
      });
      showAppSnackBar(context, '질문 기록을 삭제했습니다.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '질문 기록을 삭제하지 못했습니다.';
      showAppSnackBar(context, message);
    }
  }

  Future<void> _deleteSelectedDebates() async {
    final selectedEntries = _selectedDeletableQuestions;
    if (selectedEntries.isEmpty) {
      return;
    }

    await _deleteDebateBatch(
      entries: selectedEntries,
      successMessage: '선택한 질문 기록을 삭제했습니다.',
    );
  }

  Future<void> _deleteAllDebates() async {
    final deletableEntries = _deletableQuestions;
    if (deletableEntries.isEmpty) {
      return;
    }

    await _deleteDebateBatch(
      entries: deletableEntries,
      successMessage: '질문 기록을 모두 삭제했습니다.',
    );
  }

  Future<void> _deleteDebateBatch({
    required List<QuestionHistoryEntry> entries,
    required String successMessage,
  }) async {
    setState(() {
      _isDeletingBulk = true;
    });

    final deletedIds = <int>{};

    try {
      for (final entry in entries) {
        final debateId = entry.debateId;
        if (debateId == null) {
          continue;
        }

        try {
          await _debateApiService.deleteDebate(debateId);
          deletedIds.add(debateId);
        } catch (_) {
          // 개별 삭제 실패는 나머지 항목까지 시도한 뒤 요약 메시지로 알린다.
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeletingBulk = false;
          if (deletedIds.isNotEmpty) {
            _removeDeletedDebateIds(deletedIds);
          }
        });
      }
    }

    if (!mounted) {
      return;
    }

    final failedCount = entries.length - deletedIds.length;
    final message = failedCount == 0
        ? successMessage
        : '일부 질문 기록만 삭제했습니다. 성공 ${deletedIds.length}개, 실패 $failedCount개';
    showAppSnackBar(context, message);
  }

  void _removeDeletedDebateIds(Set<int> deletedIds) {
    _remoteQuestions = [
      for (final question in _questions)
        if (!deletedIds.contains(question.debateId)) question,
    ];
    _favoriteQuestionKeys.removeWhere((key) {
      return deletedIds.any((debateId) => key == 'debate:$debateId');
    });
    _selectedDebateIds.removeWhere(deletedIds.contains);
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;
    final totalCount = _questions.length;
    final favoriteCount = _favoriteCount;

    return Scaffold(
      body: OceanShellBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.34),
                        AppTheme.surfaceRaised.withValues(alpha: 0.52),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 128),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ArchiveTopBar(
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(height: 18),
                      QuestionHistoryArchiveSummaryCard(
                        totalCount: totalCount,
                        filteredCount: filteredQuestions.length,
                        favoriteCount: favoriteCount,
                        hasKeyword: _keyword.trim().isNotEmpty,
                        ownerNickname: widget.ownerNickname,
                      ),
                      if ((_isLoading || _loadErrorMessage != null) &&
                          totalCount > 0) ...[
                        const SizedBox(height: 12),
                        _ArchiveLoadStatus(
                          isLoading: _isLoading,
                          message: _loadErrorMessage,
                          onRetry: _loadDebates,
                        ),
                      ],
                      const SizedBox(height: 20),
                      const QuestionHistoryArchiveSectionHeader(),
                      const SizedBox(height: 12),
                      _ArchiveSearchToolbar(
                        controller: _searchController,
                        onChanged: _handleSearchChanged,
                        selectedSortMode: _sortMode,
                        onSortChanged: _handleSortChanged,
                        hasDeleteAction: _deletableQuestions.isNotEmpty,
                        selectedDeleteCount: _selectedDebateCount,
                        isDeletingBulk: _isDeletingBulk,
                        onDeleteSelected: _confirmDeleteSelectedDebates,
                        onDeleteAll: _confirmDeleteAllDebates,
                      ),
                      const SizedBox(height: 16),
                      if (totalCount == 0)
                        _EmptyHistoryState(
                          isLoading: _isLoading,
                          message: _loadErrorMessage,
                          onRetry: widget.loadFromApi ? _loadDebates : null,
                        )
                      else if (filteredQuestions.isEmpty)
                        _EmptySearchResult(onClear: _clearSearch)
                      else
                        _ArchiveQuestionList(
                          entries: filteredQuestions,
                          onQuestionTap: _openQuestionActions,
                          isSelected: _isSelected,
                          onSelectionToggle: _toggleDebateSelection,
                          isFavorite: _isFavorite,
                          onFavoriteToggle: _toggleFavorite,
                          onDeleteRequested: _confirmDeleteDebate,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionSearchBox extends StatelessWidget {
  const _QuestionSearchBox({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary.withValues(alpha: 0.88),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onChanged,
              textInputAction: TextInputAction.search,
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                hintText: '내 질문 기록 검색하기',
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
          if (controller.text.trim().isNotEmpty)
            IconButton(
              onPressed: () {
                controller.clear();
                onChanged('');
              },
              icon: const Icon(Icons.close_rounded),
              color: AppTheme.textSecondary,
              splashRadius: 18,
              tooltip: '검색 지우기',
            ),
        ],
      ),
    );
  }
}

class _ArchiveSearchToolbar extends StatelessWidget {
  const _ArchiveSearchToolbar({
    required this.controller,
    required this.onChanged,
    required this.selectedSortMode,
    required this.onSortChanged,
    required this.hasDeleteAction,
    required this.selectedDeleteCount,
    required this.isDeletingBulk,
    required this.onDeleteSelected,
    required this.onDeleteAll,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final QuestionHistorySortMode selectedSortMode;
  final ValueChanged<QuestionHistorySortMode> onSortChanged;
  final bool hasDeleteAction;
  final int selectedDeleteCount;
  final bool isDeletingBulk;
  final VoidCallback onDeleteSelected;
  final VoidCallback onDeleteAll;

  @override
  Widget build(BuildContext context) {
    final searchBox = _QuestionSearchBox(
      controller: controller,
      onChanged: onChanged,
    );

    final sortControls = QuestionHistorySortControls(
      selectedMode: selectedSortMode,
      onChanged: onSortChanged,
    );
    final deleteAction = hasDeleteAction
        ? _DeleteActionButton(
            label: selectedDeleteCount > 0 ? '선택 항목 삭제하기' : '전체 삭제',
            icon: selectedDeleteCount > 0
                ? Icons.delete_outline_rounded
                : Icons.delete_sweep_rounded,
            isDeleting: isDeletingBulk,
            onPressed: selectedDeleteCount > 0 ? onDeleteSelected : onDeleteAll,
          )
        : null;

    return OceanPanel(
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.78),
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.3),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          searchBox,
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                sortControls,
                const SizedBox(width: 12),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: deleteAction == null
                        ? const SizedBox.shrink()
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [deleteAction],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteActionButton extends StatelessWidget {
  const _DeleteActionButton({
    required this.label,
    required this.icon,
    required this.isDeleting,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isDeleting;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isDeleting ? null : onPressed,
      icon: isDeleting
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          : Icon(icon, size: 18),
      label: Text(isDeleting ? '삭제 중...' : label),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.coral,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _ArchiveQuestionList extends StatelessWidget {
  const _ArchiveQuestionList({
    required this.entries,
    required this.onQuestionTap,
    required this.isSelected,
    required this.onSelectionToggle,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onDeleteRequested,
  });

  final List<_QuestionArchiveEntry> entries;
  final ValueChanged<QuestionHistoryEntry> onQuestionTap;
  final bool Function(QuestionHistoryEntry entry) isSelected;
  final void Function(QuestionHistoryEntry entry, bool? value)
  onSelectionToggle;
  final bool Function(QuestionHistoryEntry entry) isFavorite;
  final ValueChanged<QuestionHistoryEntry> onFavoriteToggle;
  final Future<void> Function(QuestionHistoryEntry entry) onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          HistoryTile(
            question: entries[index].question,
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            borderColor: AppTheme.skyBlue.withValues(alpha: 0.14),
            showLeading: false,
            leading: entries[index].entry.debateId == null
                ? null
                : _ArchiveSelectionCheckbox(
                    value: isSelected(entries[index].entry),
                    onChanged: (value) =>
                        onSelectionToggle(entries[index].entry, value),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                QuestionHistoryFavoriteStarButton(
                  isFavorite: isFavorite(entries[index].entry),
                  onPressed: () => onFavoriteToggle(entries[index].entry),
                ),
                if (entries[index].entry.debateId != null)
                  QuestionHistoryDeleteButton(
                    onPressed: () => onDeleteRequested(entries[index].entry),
                  ),
              ],
            ),
            onTap: () => onQuestionTap(entries[index].entry),
          ),
          if (index != entries.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ArchiveSelectionCheckbox extends StatelessWidget {
  const _ArchiveSelectionCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.88,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(
          color: value
              ? AppTheme.primaryDark
              : AppTheme.skyBlue.withValues(alpha: 0.55),
          width: 1.4,
        ),
        checkColor: Colors.white,
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTheme.primaryDark;
          }
          return Colors.white.withValues(alpha: 0.92);
        }),
      ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final title = isLoading
        ? '질문 기록을 불러오는 중입니다.'
        : message != null
        ? '질문 기록을 불러오지 못했습니다.'
        : '아직 저장된 질문 기록이 없습니다.';
    final body = isLoading
        ? '실제 저장된 질문만 정리해서 가져오고 있어요.'
        : message ?? '새 토론을 시작하면 실제 질문과 답변이 여기에 쌓입니다.';

    return OceanPanel(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.82),
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.22),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            )
          else
            const Icon(
              Icons.chat_bubble_outline_rounded,
              color: AppTheme.primaryDark,
              size: 42,
            ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          if (!isLoading && onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 불러오기'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ArchiveLoadStatus extends StatelessWidget {
  const _ArchiveLoadStatus({
    required this.isLoading,
    required this.message,
    required this.onRetry,
  });

  final bool isLoading;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Colors.white.withValues(alpha: 0.74),
      child: Row(
        children: [
          if (isLoading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            )
          else
            Icon(
              Icons.info_rounded,
              color: AppTheme.primaryDark.withValues(alpha: 0.78),
              size: 20,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isLoading ? '질문 기록을 불러오는 중입니다.' : message ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (!isLoading) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ],
      ),
    );
  }
}

class _ArchiveTopBar extends StatelessWidget {
  const _ArchiveTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onBack,
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '질문 기록',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
        ),
      ],
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withValues(alpha: 0.82),
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.22),
      radius: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppTheme.primaryDark,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            '검색 결과가 없습니다.',
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            '다른 단어로 다시 검색해보세요.',
            textAlign: TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('검색 지우기'),
          ),
        ],
      ),
    );
  }
}

class _QuestionArchiveEntry {
  const _QuestionArchiveEntry({required this.number, required this.entry});

  final int number;
  final QuestionHistoryEntry entry;

  String get question => entry.question;
}
