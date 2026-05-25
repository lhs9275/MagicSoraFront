import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

/// 데모 세션의 계정 정보와 프로필 설정 진입점을 보여주는 화면이다.
class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label 기능은 준비 중입니다.')));
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileTopBar(),
                  const SizedBox(height: 18),
                  const _ProfileSummaryCard(),
                  const SizedBox(height: 18),
                  const _ActivityOverview(),
                  const SizedBox(height: 24),
                  _ProfileMenuSection(
                    onMenuTap: (label) => _showComingSoon(context, label),
                  ),
                  const SizedBox(height: 24),
                  _LogoutButton(onPressed: () => _handleLogout(context)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconActionButton(
          icon: Icons.arrow_back_rounded,
          tooltip: '뒤로가기',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('계정', style: Theme.of(context).textTheme.headlineSmall),
        ),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.accentGold,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.accentDark, width: 2),
          ),
          child: const Text(
            'DEMO',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            color: AppTheme.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cream,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accentGold, width: 3),
            ),
            child: const Text(
              'S',
              style: TextStyle(
                color: AppTheme.primaryDark,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sora Demo',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: AppTheme.cream),
                ),
                const SizedBox(height: 4),
                Text(
                  'demo@magicsora.app',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.cream.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _ProfileBadge(
                      label: 'DEMO SESSION',
                      color: AppTheme.accentGold,
                    ),
                    _ProfileBadge(
                      label: 'ACTIVE',
                      color: AppTheme.primaryLight,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ActivityOverview extends StatelessWidget {
  const _ActivityOverview();

  @override
  Widget build(BuildContext context) {
    const metrics = [
      _ActivityMetric(
        label: '저장된 토론',
        value: '12',
        icon: Icons.bookmark_rounded,
        color: AppTheme.primaryTeal,
      ),
      _ActivityMetric(
        label: '완료한 토론',
        value: '8',
        icon: Icons.check_circle_rounded,
        color: AppTheme.success,
      ),
      _ActivityMetric(
        label: '평균 점수',
        value: '82',
        icon: Icons.insights_rounded,
        color: AppTheme.accentGold,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final cardWidth = isWide
            ? (constraints.maxWidth - 24) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics)
              SizedBox(width: cardWidth, child: metric),
          ],
        );
      },
    );
  }
}

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color == AppTheme.accentGold
                        ? AppTheme.primaryDark
                        : color,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.onMenuTap});

  final ValueChanged<String> onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileMenuTile(
            icon: Icons.history_rounded,
            title: '내 토론 기록',
            subtitle: '저장된 토론과 이전 결론을 확인합니다.',
            onTap: () => onMenuTap('내 토론 기록'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.tune_rounded,
            title: '평가 기준 설정',
            subtitle: '논리성, 근거, 현실성 가중치를 조정합니다.',
            onTap: () => onMenuTap('평가 기준 설정'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.notifications_rounded,
            title: '알림 설정',
            subtitle: '토론 완료와 세션 업데이트 알림을 관리합니다.',
            onTap: () => onMenuTap('알림 설정'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.help_rounded,
            title: '도움말',
            subtitle: '토론 방식과 점수 계산 기준을 확인합니다.',
            onTap: () => onMenuTap('도움말'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.info_rounded,
            title: '앱 정보',
            subtitle: 'Magic Sora Debate 데모 버전입니다.',
            onTap: () => onMenuTap('앱 정보'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primaryDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppTheme.border);
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.coral,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.coralDark, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.coral.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: const SizedBox(
            height: 56,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryDark, width: 2),
            ),
            child: Icon(icon, color: AppTheme.primaryDark),
          ),
        ),
      ),
    );
  }
}
