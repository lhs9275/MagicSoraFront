import 'package:flutter/material.dart';

/// 로그인 이후 도착하는 임시 홈 화면이다.
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
              description: '질문 입력과 참가 에이전트 설정 기능',
            ),
            const SizedBox(height: 12),
            const _StageCard(
              title: '라운드 타임라인',
              description: '주장, 반박, 수정안을 단계별로 시각화',
            ),
            const SizedBox(height: 12),
            const _StageCard(
              title: '최종 점수',
              description: '평가 기준별 점수와 최종 결론 정리',
            ),
          ],
        ),
      ),
    );
  }
}

/// 홈 화면에서 앞으로 구현할 모듈을 카드 형태로 보여주는 위젯이다.
class _StageCard extends StatelessWidget {
  const _StageCard({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  }
}
