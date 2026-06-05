import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/home/presentation/screens/ai_conversation_detail_screen.dart';

class EvaluationItem {
  const EvaluationItem({
    required this.title,
    required this.description,
    required this.score,
  });

  final String title;
  final String description;
  final int score;
}

const List<EvaluationItem> _dummyEvaluationItems = [
  EvaluationItem(
    title: '논리성',
    description: '전제-근거-결론 연결성과 자기모순 여부',
    score: 8,
  ),
  EvaluationItem(
    title: '근거성',
    description: '구체성, 검증 가능성, claim과의 관련성',
    score: 7,
  ),
  EvaluationItem(
    title: '현실성',
    description: '현실 제약, 실행 조건, 예외 상황 고려',
    score: 6,
  ),
  EvaluationItem(
    title: '객관성',
    description: '반론, 한계, 불확실성 균형',
    score: 8,
  ),
];

class EvaluationResultScreen extends StatelessWidget {
  const EvaluationResultScreen({
    required this.question,
    required this.answer,
    super.key,
    this.items = _dummyEvaluationItems,
  });

  final String question;
  final String answer;
  final List<EvaluationItem> items;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const AiConversationDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('평가 결과')),
      body: OceanShellBackground(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 92),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OceanPanel(
                        padding: const EdgeInsets.all(20),
                        color: Colors.white.withValues(alpha: 0.76),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '마법의 소라고동 평가',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: AppTheme.primaryDark),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '더미 답변을 4가지 기준으로 임시 평가했어요.',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final item in items) ...[
                        _EvaluationCard(item: item),
                        if (item != items.last) const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 24,
              bottom: 24,
              child: TextButton(
                onPressed: () => _openDetail(context),
                child: Text(
                  '상세보기',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w900,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primaryDark,
                    decorationThickness: 1.5,
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

class _EvaluationCard extends StatelessWidget {
  const _EvaluationCard({required this.item});

  final EvaluationItem item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.score.clamp(0, 10)) / 10;

    return OceanPanel(
      padding: const EdgeInsets.all(18),
      color: Colors.white.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Text(
                '${item.score}/10',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.cream.withValues(alpha: 0.9),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
