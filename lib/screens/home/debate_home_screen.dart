import 'package:flutter/material.dart';

import 'final_score_screen.dart';

/// 로그인 이후에 보이는 홈 화면이다.
class DebateHomeScreen extends StatelessWidget {
  const DebateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Debate Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('다음 구현 단계', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(
              '이 화면 다음에는 토론 세션 생성, 라운드 진행, 점수 시각화 기능이 들어갈 예정이다.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            const _StageCard(
              title: '토론 생성',
              description: '질문 입력과 참가 AI 에이전트 설정 기능',
            ),
            const SizedBox(height: 12),
            const _StageCard(
              title: '라운드 타임라인',
              description: '주장, 반박, 수정 의견을 단계별로 시각화',
            ),
            const SizedBox(height: 12),
            _StageCard(
              title: '최종 점수',
              description: '평가 기준별 점수와 최종 결론 정리',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FinalScoreScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈 화면에서 앞으로 구현할 모듈을 카드 형태로 보여준다.
class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.title,
    required this.description,
    this.onTap,
  });

  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(description),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
