import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
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
  });

  final List<QuestionHistoryEntry> questions;
  final bool loadFromApi;
  final DebateApiService? debateApiService;

  @override
  State<QuestionHistoryScreen> createState() => _QuestionHistoryScreenState();
}

class _QuestionHistoryScreenState extends State<QuestionHistoryScreen> {
  final _searchController = TextEditingController();
  late final DebateApiService _debateApiService;

  String _keyword = '';
  List<QuestionHistoryEntry>? _remoteQuestions;
  final Set<String> _favoriteQuestionKeys = <String>{};
  QuestionHistorySortMode _sortMode = QuestionHistorySortMode.date;
  bool _isSortAscending = false;
  bool _isLoading = false;
  String? _loadErrorMessage;

  List<QuestionHistoryEntry> get _questions =>
      _remoteQuestions ?? widget.questions;

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

  List<_QuestionArchiveEntry> _sortEntries(List<_QuestionArchiveEntry> entries) {
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

  void _toggleSortDirection() {
    setState(() {
      _isSortAscending = !_isSortAscending;
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
      onDelete: entry.debateId == null ? null : _deleteDebate,
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
        _remoteQuestions = page.items.map(_entryFromDebateSummary).toList();
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

  QuestionHistoryEntry _entryFromDebateSummary(DebateSummary summary) {
    return QuestionHistoryEntry(
      question: summary.topic,
      answer: summary.finalVerdict ?? _fallbackAnswerFor(summary),
      debateId: summary.id,
      status: summary.status,
      createdAt: summary.createdAt,
    );
  }

  String _fallbackAnswerFor(DebateSummary summary) {
    return switch (summary.status) {
      DebateStatus.running => '토론이 진행 중입니다.',
      DebateStatus.cancelled => '취소된 토론입니다.',
      DebateStatus.failed =>
        summary.errorCode == null
            ? '토론이 실패했습니다.'
            : '토론이 실패했습니다. ${summary.errorCode}',
      DebateStatus.degraded => '일부 단계가 실패했지만 결과가 저장되었습니다.',
      DebateStatus.done => '저장된 최종 답변이 없습니다.',
    };
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
        _favoriteQuestionKeys.remove(_favoriteKeyFor(entry));
        _remoteQuestions = [
          for (final question in _questions)
            if (question.debateId != debateId) question,
        ];
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('질문 기록을 삭제했습니다.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '질문 기록을 삭제하지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;
    final hasKeyword = _keyword.trim().isNotEmpty;
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
                        hasKeyword: hasKeyword,
                      ),
                      if (_isLoading || _loadErrorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ArchiveLoadStatus(
                          isLoading: _isLoading,
                          message: _loadErrorMessage,
                          onRetry: _loadDebates,
                        ),
                      ],
                      const SizedBox(height: 16),
                      OceanPanel(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white.withValues(alpha: 0.78),
                        borderColor: AppTheme.skyBlue.withValues(alpha: 0.3),
                        radius: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _QuestionSearchBox(
                              controller: _searchController,
                              onChanged: _handleSearchChanged,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.tips_and_updates_outlined,
                                  color: AppTheme.primaryDark.withValues(
                                    alpha: 0.72,
                                  ),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '띄어쓰기 없이, 초성으로도 질문을 찾을 수 있어요.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      QuestionHistoryArchiveSectionHeader(
                        totalCount: totalCount,
                        filteredCount: filteredQuestions.length,
                        hasKeyword: hasKeyword,
                        selectedSortMode: _sortMode,
                        isSortAscending: _isSortAscending,
                        onSortChanged: _handleSortChanged,
                        onSortDirectionToggle: _toggleSortDirection,
                      ),
                      const SizedBox(height: 12),
                      if (filteredQuestions.isEmpty)
                        _EmptySearchResult(onClear: _clearSearch)
                      else
                        _ArchiveQuestionList(
                          entries: filteredQuestions,
                          onQuestionTap: _openQuestionActions,
                          isFavorite: _isFavorite,
                          onFavoriteToggle: _toggleFavorite,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: OceanPillButton(
                    label: '채팅으로 돌아가기',
                    icon: Icons.chat_bubble_rounded,
                    backgroundColor: AppTheme.deepNavy,
                    foregroundColor: Colors.white,
                    onPressed: () => Navigator.of(context).maybePop(),
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

class _ArchiveQuestionList extends StatelessWidget {
  const _ArchiveQuestionList({
    required this.entries,
    required this.onQuestionTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  final List<_QuestionArchiveEntry> entries;
  final ValueChanged<QuestionHistoryEntry> onQuestionTap;
  final bool Function(QuestionHistoryEntry entry) isFavorite;
  final ValueChanged<QuestionHistoryEntry> onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          HistoryTile(
            question: entries[index].question,
            index: entries[index].number,
            backgroundColor: Colors.white.withValues(alpha: 0.92),
            borderColor: AppTheme.skyBlue.withValues(alpha: 0.14),
            trailing: QuestionHistoryFavoriteStarButton(
              isFavorite: isFavorite(entries[index].entry),
              onPressed: () => onFavoriteToggle(entries[index].entry),
            ),
            onTap: () => onQuestionTap(entries[index].entry),
          ),
          if (index != entries.length - 1) const SizedBox(height: 10),
        ],
      ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '질문 기록',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '다시 찾는 질문 아카이브',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
            ],
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
