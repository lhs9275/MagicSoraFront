import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_result_screen.dart';

const _historySurface = Color(0x99FFFFFF);
const _historySurfaceStrong = Color(0xFFF8FFFD);
const _historyRow = Color(0xFFF2FBFA);
const _historySearchFill = Color(0xFFEAF8F6);
const _historyDivider = Color(0xFFCFE8E5);
const _historyAccentSoft = Color(0xFFE3F6F4);

class QuestionHistoryScreen extends StatefulWidget {
  const QuestionHistoryScreen({required this.questions, super.key});

  final List<String> questions;

  @override
  State<QuestionHistoryScreen> createState() => _QuestionHistoryScreenState();
}

class _QuestionHistoryScreenState extends State<QuestionHistoryScreen> {
  final _searchController = TextEditingController();
  String _keyword = '';

  List<String> get _filteredQuestions {
    final rawKeyword = _keyword.trim().toLowerCase();
    final keyword = _compactSearchText(rawKeyword);
    final keywordInitials = _toHangulInitials(keyword);

    if (keyword.isEmpty) {
      return widget.questions;
    }

    return widget.questions.where((question) {
      final rawQuestion = question.toLowerCase();
      final questionText = _compactSearchText(rawQuestion);
      final questionInitials = _toHangulInitials(questionText);
      final questionWordInitials = _toHangulWordInitials(rawQuestion);

      return questionText.contains(keyword) ||
          questionInitials.contains(keyword) ||
          questionInitials.contains(keywordInitials) ||
          questionWordInitials.contains(keyword) ||
          questionWordInitials.contains(keywordInitials);
    }).toList();
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

  void _openQuestion(String question) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MagicConchResultScreen(question: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;
    final hasKeyword = _keyword.trim().isNotEmpty;

    return Scaffold(
      body: OceanShellBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
              child: OceanPanel(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                color: _historySurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HistoryTopBar(
                      totalCount: widget.questions.length,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(height: 16),
                    _QuestionSearchBox(
                      controller: _searchController,
                      hasText: hasKeyword,
                      onChanged: _handleSearchChanged,
                      onClear: _clearSearch,
                    ),
                    const SizedBox(height: 14),
                    _HistoryListHeader(
                      count: filteredQuestions.length,
                      hasKeyword: hasKeyword,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filteredQuestions.isEmpty
                          ? _EmptySearchResult(hasKeyword: hasKeyword)
                          : _QuestionHistoryList(
                              questions: filteredQuestions,
                              onQuestionTap: _openQuestion,
                            ),
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

class _HistoryTopBar extends StatelessWidget {
  const _HistoryTopBar({required this.totalCount, required this.onBack});

  final int totalCount;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: _historyAccentSoft,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const SizedBox.square(
              dimension: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary,
                size: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '질문 기록',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$totalCount개의 질문을 모아봤어요',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestionSearchBox extends StatelessWidget {
  const _QuestionSearchBox({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: AppTheme.primaryDark,
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w800,
      ),
      decoration: InputDecoration(
        hintText: '질문 검색',
        hintStyle: TextStyle(
          color: AppTheme.textSecondary.withValues(alpha: 0.72),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppTheme.primaryDark,
          size: 22,
        ),
        suffixIcon: hasText
            ? IconButton(
                tooltip: '검색어 지우기',
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: _historySearchFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _historyDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _historyDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }
}

class _HistoryListHeader extends StatelessWidget {
  const _HistoryListHeader({required this.count, required this.hasKeyword});

  final int count;
  final bool hasKeyword;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          hasKeyword ? '검색 결과' : '최근 질문',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          '$count개',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _QuestionHistoryList extends StatelessWidget {
  const _QuestionHistoryList({
    required this.questions,
    required this.onQuestionTap,
  });

  final List<String> questions;
  final ValueChanged<String> onQuestionTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 2),
      itemCount: questions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final question = questions[index];

        return _QuestionHistoryTile(
          question: question,
          onTap: () => onQuestionTap(question),
        );
      },
    );
  }
}

class _QuestionHistoryTile extends StatelessWidget {
  const _QuestionHistoryTile({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _historyRow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _historyAccentSoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: _historyDivider),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppTheme.primaryDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.34,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult({required this.hasKeyword});

  final bool hasKeyword;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _historySurfaceStrong,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _historyDivider),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasKeyword
                    ? Icons.search_off_rounded
                    : Icons.history_toggle_off_rounded,
                color: AppTheme.primaryDark,
                size: 34,
              ),
              const SizedBox(height: 14),
              Text(
                hasKeyword ? '검색 결과가 없어요' : '아직 질문 기록이 없어요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                hasKeyword ? '다른 단어로 다시 찾아보세요.' : '질문을 남기면 여기에 쌓입니다.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
