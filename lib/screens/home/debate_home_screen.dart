import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../account/account_profile_screen.dart';

/// 로그인 이후 도착하는 토론 게임 대시보드다.
class DebateHomeScreen extends StatelessWidget {
  const DebateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _HomeTopBar(),
                  const SizedBox(height: 18),
                  const _HeroScorePanel(),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    icon: Icons.style_rounded,
                    title: '라운드 스코어',
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 680;
                      final cardWidth = isWide
                          ? (constraints.maxWidth - 24) / 3
                          : constraints.maxWidth;
                      const metricCards = [
                        _ScoreMetricCard(
                          title: '논리력',
                          value: '86',
                          caption: '+12 combo',
                          accent: AppTheme.primaryTeal,
                          icon: Icons.psychology_rounded,
                        ),
                        _ScoreMetricCard(
                          title: '반박',
                          value: '74',
                          caption: 'steady',
                          accent: AppTheme.accentGold,
                          icon: Icons.bolt_rounded,
                          highlighted: true,
                        ),
                        _ScoreMetricCard(
                          title: 'BOOM',
                          value: '03',
                          caption: 'risk cards',
                          accent: AppTheme.coral,
                          icon: Icons.local_fire_department_rounded,
                          boom: true,
                        ),
                      ];

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final card in metricCards)
                            SizedBox(width: cardWidth, child: card),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    icon: Icons.casino_rounded,
                    title: '진행 카드',
                  ),
                  const SizedBox(height: 14),
                  const _RoundActionCard(
                    title: '주장 카드',
                    description: '핵심 근거 3개 확보',
                    state: 'ACTIVE',
                    color: AppTheme.primaryTeal,
                    icon: Icons.record_voice_over_rounded,
                  ),
                  const SizedBox(height: 12),
                  const _RoundActionCard(
                    title: 'Flip7 보너스',
                    description: '서로 다른 관점 7개 완성',
                    state: '+21',
                    color: AppTheme.skyBlue,
                    icon: Icons.auto_awesome_rounded,
                    highlighted: true,
                  ),
                  const SizedBox(height: 12),
                  const _RoundActionCard(
                    title: 'BOOM 체크',
                    description: '근거 충돌 1건 검토',
                    state: 'WAIT',
                    color: AppTheme.coral,
                    icon: Icons.warning_amber_rounded,
                    boom: true,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(
                    icon: Icons.emoji_events_rounded,
                    title: '리더보드',
                  ),
                  const SizedBox(height: 14),
                  const _RankingTile(
                    rank: 1,
                    name: 'Sora',
                    score: 181,
                    color: AppTheme.accentGold,
                    medal: 'WIN',
                    winner: true,
                  ),
                  const SizedBox(height: 10),
                  const _RankingTile(
                    rank: 2,
                    name: 'Nova',
                    score: 154,
                    color: Color(0xFFAEB7C2),
                    medal: '2ND',
                  ),
                  const SizedBox(height: 10),
                  const _RankingTile(
                    rank: 3,
                    name: 'Rune',
                    score: 132,
                    color: AppTheme.coral,
                    medal: '3RD',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryDark, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.style_rounded, color: AppTheme.primaryDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Magic Sora',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(letterSpacing: 0.8),
          ),
        ),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.accentDark, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentGold.withValues(alpha: 0.36),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            'ROUND 07',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const _ProfileDemoButton(),
      ],
    );
  }
}

class _ProfileDemoButton extends StatelessWidget {
  const _ProfileDemoButton();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '계정 프로필',
      child: Material(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AccountProfileScreen(),
              ),
            );
          },
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryDark, width: 2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  color: AppTheme.primaryDark,
                  size: 20,
                ),
                SizedBox(width: 6),
                Text(
                  '프로필',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroScorePanel extends StatelessWidget {
  const _HeroScorePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primaryTeal],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryDark, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.cream,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'DEBATE ARENA',
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: AppTheme.accentGold),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            '181',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 64,
              fontWeight: FontWeight.w900,
              height: 0.95,
              shadows: [
                Shadow(color: Color(0xAA173D3A), offset: Offset(2.5, 2.5)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '현재 선두 · Flip7 보너스 대기',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.cream),
          ),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(
                child: _HeroPill(
                  label: 'COMBO',
                  value: 'x4',
                  color: AppTheme.accentGold,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _HeroPill(
                  label: 'SAFE',
                  value: '92%',
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.cream,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreMetricCard extends StatelessWidget {
  const _ScoreMetricCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.accent,
    required this.icon,
    this.highlighted = false,
    this.boom = false,
  });

  final String title;
  final String value;
  final String caption;
  final Color accent;
  final IconData icon;
  final bool highlighted;
  final bool boom;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: highlighted
              ? [
                  AppTheme.accentGold.withValues(alpha: 0.26),
                  AppTheme.surfaceCard,
                ]
              : boom
              ? [AppTheme.coral.withValues(alpha: 0.13), AppTheme.surfaceCard]
              : const [AppTheme.surfaceCard, AppTheme.surfaceCard],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: highlighted || boom ? 0.24 : 0.1),
            blurRadius: highlighted || boom ? 22 : 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accent, size: 24),
                    const Spacer(),
                    if (highlighted || boom)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          boom ? 'BOOM' : 'HOT',
                          style: TextStyle(
                            color: accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    color: boom ? AppTheme.coral : AppTheme.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    height: 0.95,
                  ),
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
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

class _RoundActionCard extends StatelessWidget {
  const _RoundActionCard({
    required this.title,
    required this.description,
    required this.state,
    required this.color,
    required this.icon,
    this.highlighted = false,
    this.boom = false,
  });

  final String title;
  final String description;
  final String state;
  final Color color;
  final IconData icon;
  final bool highlighted;
  final bool boom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: highlighted
              ? [
                  AppTheme.accentGold.withValues(alpha: 0.22),
                  AppTheme.surfaceCard,
                ]
              : boom
              ? [AppTheme.coral.withValues(alpha: 0.14), AppTheme.surfaceCard]
              : const [AppTheme.surfaceCard, AppTheme.surfaceCard],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: boom ? 0.2 : 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              constraints: const BoxConstraints(minWidth: 58),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.26),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  state,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
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

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.rank,
    required this.name,
    required this.score,
    required this.color,
    required this.medal,
    this.winner = false,
  });

  final int rank;
  final String name;
  final int score;
  final Color color;
  final String medal;
  final bool winner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(winner ? 18 : 15),
      decoration: BoxDecoration(
        gradient: winner
            ? LinearGradient(
                colors: [
                  AppTheme.accentGold.withValues(alpha: 0.28),
                  AppTheme.surfaceCard,
                ],
              )
            : null,
        color: winner ? null : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: winner ? 0.5 : 0.24)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: winner ? 0.28 : 0.1),
            blurRadius: winner ? 24 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: winner ? 58 : 50,
            height: winner ? 58 : 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.82), color],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: winner ? AppTheme.primaryDark : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                color: winner ? AppTheme.primaryDark : Colors.white,
                fontSize: winner ? 24 : 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  medal,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              color: winner ? AppTheme.primaryDark : color,
              fontSize: winner ? 32 : 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primaryDark, width: 2),
              ),
              child: Icon(icon, color: AppTheme.primaryDark, size: 22),
            ),
            const SizedBox(width: 10),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        const _DashedDivider(),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedDividerPainter(),
      size: const Size(double.infinity, 2),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 1), Offset(x + 8, 1), paint);
      x += 14;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
