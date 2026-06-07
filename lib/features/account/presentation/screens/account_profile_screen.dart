import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

const _accountSurface = Color(0xFFFFFFFF);
const _accountSurfaceWash = Color(0xFFFFF7FB);
const _accountAccent = Color(0xFFFF8FB4);
const _accountAccentStrong = Color(0xFFE95D91);
const _accountSky = Color(0xFF7BD7FF);
const _accountWarm = Color(0xFFFFF0B6);
const _accountLine = Color(0xFFF0DCE8);
const _accountText = Color(0xFF4F4051);
const _accountTextMuted = Color(0xFF8B7283);
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
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 22.0;
            final verticalPadding = constraints.maxHeight < 700 ? 18.0 : 26.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileTopBar(user: user),
                      const SizedBox(height: 18),
                      _ProfileHero(user: user),
                      const SizedBox(height: 14),
                      _AccountDetailsPanel(user: user),
                      const SizedBox(height: 14),
                      _ProfileMenuSection(
                        onMenuTap: (label) => _showComingSoon(context, label),
                      ),
                      const SizedBox(height: 16),
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
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '계정정보',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: _accountText,
                  fontSize: 28,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.isDemo ? '데모 세션으로 이용 중' : '${user.loginProvider} 계정 연결됨',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _accountTextMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ProviderMark(label: user.isDemo ? 'DEMO' : user.loginProvider),
      ],
    );
  }
}

class _ProviderMark extends StatelessWidget {
  const _ProviderMark({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accountWarm, _accountAccent],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.86)),
        boxShadow: [
          BoxShadow(
            color: _accountAccent.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _accountText,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final sessionCopy = user.isDemo
        ? '토론 기록은 데모 세션 기준으로 표시됩니다.'
        : '계정 연결 상태가 정상입니다.';

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _accountSurface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.84)),
        boxShadow: [
          BoxShadow(
            color: _accountAccent.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.72),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            top: -36,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _accountSky.withValues(alpha: 0.36),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 118, height: 118),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileAvatar(
                    imageUrl: user.profileImageUrl,
                    providerLabel: user.isDemo ? '데모' : user.loginProvider,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.nickname,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: _accountText,
                                  fontSize: 31,
                                  height: 1.08,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.accountLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: _accountTextMuted,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _SessionStatusStrip(
                title: user.isDemo ? '데모 모드' : '로그인 유지 중',
                subtitle: sessionCopy,
                icon: user.isDemo
                    ? Icons.person_outline_rounded
                    : Icons.verified_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl, required this.providerLabel});

  final String? imageUrl;
  final String providerLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 94,
          height: 94,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accountSurfaceWash,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _accountLine, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: _accountAccent.withValues(alpha: 0.2),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: _ProfileAvatarImage(imageUrl: imageUrl),
        ),
        Positioned(
          right: -6,
          bottom: -7,
          child: Container(
            height: 27,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accountWarm,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              providerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _accountText,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
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
      return const _FallbackAvatarAsset();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.network(
        profileUrl,
        width: 82,
        height: 82,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const _FallbackAvatarAsset();
        },
      ),
    );
  }
}

class _FallbackAvatarAsset extends StatelessWidget {
  const _FallbackAvatarAsset();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/brand/magic_conch.png',
      width: 72,
      fit: BoxFit.contain,
      semanticLabel: '마법의 소라고동 프로필 이미지',
    );
  }
}

class _SessionStatusStrip extends StatelessWidget {
  const _SessionStatusStrip({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accountAccent.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: _accountAccentStrong, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _accountText,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _accountTextMuted,
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

class _AccountDetailsPanel extends StatelessWidget {
  const _AccountDetailsPanel({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      color: _accountSurface.withValues(alpha: 0.9),
      borderColor: Colors.white.withValues(alpha: 0.72),
      radius: 24,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(title: '계정 상세', trailing: user.isDemo ? '임시' : '연결됨'),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.account_circle_outlined,
            label: '로그인 방식',
            value: user.loginProvider,
          ),
          const _DetailDivider(),
          _DetailRow(
            icon: Icons.alternate_email_rounded,
            label: '이메일',
            value: user.email?.trim().isNotEmpty == true
                ? user.email!
                : '등록된 이메일 없음',
          ),
          const _DetailDivider(),
          _DetailRow(
            icon: Icons.folder_open_rounded,
            label: '기록 상태',
            value: user.isDemo ? '데모 기록' : '계정 기록 연결',
          ),
          const _DetailDivider(),
          const _DetailRow(
            icon: Icons.auto_awesome_rounded,
            label: '앱 버전',
            value: '1.0',
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: _accountText, fontSize: 18),
          ),
        ),
        Text(
          trailing,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: _accountAccentStrong,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: _accountAccentStrong, size: 21),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _accountTextMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _accountText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailDivider extends StatelessWidget {
  const _DetailDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: _accountLine.withValues(alpha: 0.7),
      indent: 34,
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.onMenuTap});

  final ValueChanged<String> onMenuTap;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
      color: _accountSurface.withValues(alpha: 0.9),
      borderColor: Colors.white.withValues(alpha: 0.72),
      radius: 24,
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: _PanelHeader(title: '설정과 기록', trailing: '예정'),
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
        borderRadius: BorderRadius.circular(18),
        highlightColor: _accountAccent.withValues(alpha: 0.08),
        splashColor: _accountAccent.withValues(alpha: 0.1),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _accountSurfaceWash.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _accountLine, width: 1),
                ),
                child: Icon(icon, color: _accountAccentStrong, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _accountText,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _accountTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: _accountTextMuted,
                size: 24,
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
    return Divider(
      height: 1,
      color: _accountLine.withValues(alpha: 0.62),
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        highlightColor: _accountDanger.withValues(alpha: 0.08),
        splashColor: _accountDanger.withValues(alpha: 0.1),
        onTap: onPressed,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _accountDangerSoft.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _accountDanger.withValues(alpha: 0.24)),
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
                  fontWeight: FontWeight.w900,
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
        color: _accountSurface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          highlightColor: _accountAccent.withValues(alpha: 0.08),
          splashColor: _accountAccent.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            ),
            child: Icon(icon, color: _accountText),
          ),
        ),
      ),
    );
  }
}
