import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

const _accountCanvas = Color(0xFFFBFCFA);
const _accountSurface = Color(0xFFFFFFFF);
const _accountSurfaceTint = Color(0xFFF7FAF8);
const _accountAccent = Color(0xFF2E8F87);
const _accountAccentSoft = Color(0xFFEAF6F3);
const _accountLine = Color(0xFFE1ECE8);
const _accountDanger = Color(0xFFC75E6E);
const _accountDangerSoft = Color(0xFFFFF4F6);

/// 로그인한 사용자의 계정 정보와 프로필 설정 진입점을 보여주는 화면이다.
class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({super.key, AppUser? user})
    : user = user ?? AppUser.fallback;

  final AppUser user;

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label은 아직 준비 중입니다.')));
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (user.loginProvider == '카카오' && !user.isDemo) {
      try {
        await UserApi.instance.logout();
      } catch (_) {
        // 로컬 화면 전환은 계속 진행해 사용자가 세션에서 빠져나갈 수 있게 한다.
      }
    }

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _accountCanvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final verticalPadding = constraints.maxHeight < 700 ? 18.0 : 24.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileTopBar(user: user),
                      const SizedBox(height: 18),
                      _ProfileSummaryCard(user: user),
                      const SizedBox(height: 18),
                      _ProfileMenuSection(
                        onMenuTap: (label) => _showComingSoon(context, label),
                      ),
                      const SizedBox(height: 18),
                      _LogoutButton(onPressed: () => _handleLogout(context)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.user});

  final AppUser user;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('계정', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                user.isDemo ? '데모 세션' : '${user.loginProvider}로 로그인됨',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _DemoBadge(label: user.isDemo ? '데모' : user.loginProvider),
      ],
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _accountSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _accountLine, width: 1),
        boxShadow: [
          BoxShadow(
            color: _accountAccent.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: _accountAccent,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      color: _accountSurface.withValues(alpha: 0.92),
      borderColor: _accountLine,
      showShadow: false,
      child: Column(
        children: [
          Row(
            children: [
              _ProfileAvatar(imageUrl: user.profileImageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.accountLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ProfileBadge(
                          icon: user.isDemo
                              ? Icons.person_outline_rounded
                              : Icons.account_circle_rounded,
                          label: user.isDemo ? '데모 세션' : user.loginProvider,
                          color: _accountAccent,
                        ),
                        const _ProfileBadge(
                          icon: Icons.check_circle_rounded,
                          label: '로그인 중',
                          color: _accountAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileMetaStrip(user: user),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _accountSurfaceTint,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accountAccentSoft, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: _accountAccent.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _ProfileAvatarImage(imageUrl: imageUrl),
    );
  }
}

class _ProfileMetaStrip extends StatelessWidget {
  const _ProfileMetaStrip({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _accountSurfaceTint.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accountLine),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ProfileMetaItem(label: '로그인', value: user.loginProvider),
          ),
          const _MetaDivider(),
          Expanded(
            child: _ProfileMetaItem(
              label: '기록',
              value: user.isDemo ? '데모' : '연결',
            ),
          ),
          const _MetaDivider(),
          const Expanded(
            child: _ProfileMetaItem(label: '버전', value: '1.0'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarImage extends StatelessWidget {
  const _ProfileAvatarImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final profileUrl = imageUrl;

    if (profileUrl == null) {
      return Image.asset(
        'assets/images/brand/magic_conch.png',
        width: 68,
        fit: BoxFit.contain,
        semanticLabel: '마법의 소라고동 프로필 이미지',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        profileUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/brand/magic_conch.png',
            width: 68,
            fit: BoxFit.contain,
            semanticLabel: '마법의 소라고동 프로필 이미지',
          );
        },
      ),
    );
  }
}

class _ProfileMetaItem extends StatelessWidget {
  const _ProfileMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _accountAccent,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _MetaDivider extends StatelessWidget {
  const _MetaDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: _accountLine.withValues(alpha: 0.9),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final foreground = Color.lerp(color, AppTheme.textPrimary, 0.2)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w900,
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
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      color: _accountSurface.withValues(alpha: 0.9),
      borderColor: _accountLine,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '계정 관리',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accountAccentSoft.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(AppTheme.controlRadius),
                    border: Border.all(color: _accountLine),
                  ),
                  child: Text(
                    '준비 중',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _accountAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
            icon: Icons.notifications_none_rounded,
            title: '알림 설정',
            subtitle: '토론 완료와 세션 업데이트 알림을 관리합니다.',
            onTap: () => onMenuTap('알림 설정'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: '도움말',
            subtitle: '토론 방식과 점수 계산 기준을 확인합니다.',
            onTap: () => onMenuTap('도움말'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.info_outline_rounded,
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
        borderRadius: BorderRadius.circular(20),
        highlightColor: _accountAccentSoft.withValues(alpha: 0.44),
        splashColor: _accountAccent.withValues(alpha: 0.1),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 70),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accountSurfaceTint.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _accountLine, width: 1),
                  ),
                  child: Icon(icon, color: _accountAccent, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _accountSurfaceTint.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _accountLine),
                  ),
                  child: const Text(
                    '준비',
                    style: TextStyle(
                      color: _accountAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
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

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: _accountLine.withValues(alpha: 0.6),
      indent: 64,
      endIndent: 8,
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accountDangerSoft.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _accountDanger.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: _accountDanger.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.logout_rounded, color: _accountDanger, size: 20),
              SizedBox(width: 8),
              Text(
                '로그아웃',
                style: TextStyle(
                  color: _accountDanger,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
        color: _accountSurface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          highlightColor: _accountAccentSoft.withValues(alpha: 0.52),
          splashColor: _accountAccent.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _accountLine, width: 1),
              boxShadow: [
                BoxShadow(
                  color: _accountAccent.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}
