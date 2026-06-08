import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = _filteredQuestions;

    return Scaffold(
      body: OceanShellBackground(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 116),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QuestionSearchBox(
                        controller: _searchController,
                        onChanged: _handleSearchChanged,
                      ),
                      const SizedBox(height: 22),
                      if (filteredQuestions.isEmpty)
                        const _EmptySearchResult()
                      else
                        _PlainQuestionHistoryList(
                          questions: filteredQuestions,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 24,
              child: SizedBox(
                width: 190,
                child: OceanPillButton(
                  label: '채팅으로 돌아가기',
                  icon: Icons.chat_bubble_rounded,
                  backgroundColor: AppTheme.deepNavy,
                  foregroundColor: Colors.white,
                  onPressed: () => Navigator.of(context).maybePop(),
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
  const _QuestionSearchBox({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: '내가 질문한 것들 검색하기',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: AppTheme.primaryDark.withValues(alpha: 0.32),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: AppTheme.primaryDark.withValues(alpha: 0.28),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(
            color: AppTheme.primaryTeal,
            width: 1.6,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }
}

class _PlainQuestionHistoryList extends StatelessWidget {
  const _PlainQuestionHistoryList({required this.questions});

  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내가 여태까지 질문했던 목록들',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        for (final question in questions) ...[
          Text(
            question,
            textAlign: TextAlign.left,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (question != questions.last) const _QuestionDivider(),
        ],
      ],
    );
  }
}

class _QuestionDivider extends StatelessWidget {
  const _QuestionDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: double.infinity,
      child: CustomPaint(
        painter: _QuestionDividerPainter(
          color: AppTheme.primaryDark.withValues(alpha: 0.13),
        ),
      ),
    );
  }
}

class _QuestionDividerPainter extends CustomPainter {
  const _QuestionDividerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final y = size.height / 2;
    canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), paint);
  }

  @override
  bool shouldRepaint(covariant _QuestionDividerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Column(
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
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
