import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

const _accountSurface = Color(0xFFFFFFFF);
const _accountSurfaceSoft = Color(0xFFF7FBFF);
const _accountSurfaceLavender = Color(0xFFF1F4FF);
const _accountLine = Color(0xFFDCE5F2);
const _accountLineStrong = Color(0xFFC7D4E9);
const _accountText = Color(0xFF30476D);
const _accountTextMuted = Color(0xFF6C7C9B);
const _accountTeal = Color(0xFF75D6E6);
const _accountTealStrong = Color(0xFF4A69AA);
const _accountSky = Color(0xFFC8D2FF);
const _accountGold = Color(0xFFF6DE88);
const _accountIconBgTop = Color(0xFFF9FBFF);
const _accountIconBgBottom = Color(0xFFEBF1FF);
const _accountDanger = Color(0xFFC75E6E);
const _accountDangerSoft = Color(0xFFFFF5F6);
const _accountSheetBarrier = Color(0x332B4B80);

/// 로그인한 사용자의 계정 정보와 프로필 설정 진입점을 보여주는 화면이다.
class AccountProfileScreen extends StatelessWidget {
  const AccountProfileScreen({
    super.key,
    AppUser? user,
    this.onOpenQuestionHistory,
  })
    : user = user ?? AppUser.fallback;

  final AppUser user;
  final VoidCallback? onOpenQuestionHistory;

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

    await AuthSessionStore.instance.clear();

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainMenuScreen()),
      (route) => false,
    );
  }

  Future<void> _showAccountDetails(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: _accountSheetBarrier,
      isScrollControlled: false,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: _AccountDetailsSheet(user: user),
        );
      },
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
                      _ProfileHero(
                        user: user,
                        onTap: () => _showAccountDetails(context),
                      ),
                      const SizedBox(height: 14),
                      _ProfileMenuSection(
                        onOpenQuestionHistory: onOpenQuestionHistory,
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
    final subtitle = user.isDemo ? '데모 세션 연결됨' : '${user.loginProvider} 계정 연결됨';

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
                subtitle,
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
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user, required this.onTap});

  final AppUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        highlightColor: _accountTeal.withValues(alpha: 0.06),
        splashColor: _accountTeal.withValues(alpha: 0.08),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.86),
                Colors.white.withValues(alpha: 0.72),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x334C8ED4),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.78),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -24,
                top: -30,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _accountSky.withValues(alpha: 0.42),
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(width: 128, height: 128),
                ),
              ),
              Positioned(
                left: -12,
                right: -12,
                bottom: -52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.52),
                        _accountTeal.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(height: 96),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileAvatar(
                          imageUrl: user.profileImageUrl,
                          providerLabel: user.isDemo
                              ? '데모'
                              : user.loginProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.nickname,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        color: _accountText,
                                        fontSize: 31,
                                        height: 1.04,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '질문기록 연결됨',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: _accountTextMuted,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                _HeroStatusPill(
                                  label: user.isDemo
                                      ? '데모 세션'
                                      : '${user.loginProvider} 로그인됨',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _accountEmail(user),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: _accountText,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _SessionStatusStrip(
                      title: '계정 상세',
                      subtitle: user.isDemo
                          ? '세션 정보와 연결 상태 보기'
                          : '카카오 로그인과 이메일 보기',
                      icon: user.isDemo
                          ? Icons.person_outline_rounded
                          : Icons.verified_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          width: 92,
          height: 92,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_accountSurface, _accountSurfaceLavender],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withValues(alpha: 0.96)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x224C8ED4),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accountSurfaceSoft, _accountSurfaceLavender],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            alignment: Alignment.center,
            child: _ProfileAvatarImage(imageUrl: imageUrl),
          ),
        ),
        Positioned(
          right: -4,
          bottom: -6,
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [_accountGold, _accountSurfaceLavender],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              providerLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _accountTealStrong,
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
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        profileUrl,
        width: 68,
        height: 68,
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
      width: 60,
      fit: BoxFit.contain,
      semanticLabel: '마법의 소라고동 프로필 이미지',
    );
  }
}

class _HeroStatusPill extends StatelessWidget {
  const _HeroStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [_accountIconBgTop, _accountIconBgBottom],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _accountLineStrong),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _accountTealStrong,
          fontWeight: FontWeight.w900,
          height: 1.1,
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accountLineStrong.withValues(alpha: 0.88)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accountIconBgTop, _accountIconBgBottom],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _accountLineStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x184C8ED4),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: _accountTealStrong, size: 20),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _accountTextMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.chevron_right_rounded,
            color: _accountTextMuted,
            size: 22,
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({
    required this.onMenuTap,
    this.onOpenQuestionHistory,
  });

  final ValueChanged<String> onMenuTap;
  final VoidCallback? onOpenQuestionHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.88)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144C8ED4),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: _PanelHeader(title: '기록과 설정'),
          ),
          _ProfileMenuTile(
            icon: Icons.history_rounded,
            title: '질문기록',
            subtitle: '남긴 질문 다시 보기',
            onTap: onOpenQuestionHistory ?? () => onMenuTap('질문기록'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.tune_rounded,
            title: '평가 기준',
            subtitle: '가중치 조정',
            onTap: () => onMenuTap('평가 기준'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.notifications_none_rounded,
            title: '알림 설정',
            subtitle: '도착 방식 관리',
            onTap: () => onMenuTap('알림 설정'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.help_outline_rounded,
            title: '도움말',
            subtitle: '사용법 확인',
            onTap: () => onMenuTap('도움말'),
          ),
          const _MenuDivider(),
          _ProfileMenuTile(
            icon: Icons.info_outline_rounded,
            title: '앱 정보',
            subtitle: '현재 버전 확인',
            onTap: () => onMenuTap('앱 정보'),
          ),
        ],
      ),
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(color: _accountText, fontSize: 18),
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
        highlightColor: _accountTeal.withValues(alpha: 0.08),
        splashColor: _accountTeal.withValues(alpha: 0.1),
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
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_accountIconBgTop, _accountIconBgBottom],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _accountLineStrong),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x124C8ED4),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, color: _accountTealStrong, size: 21),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _accountTextMuted,
                        fontWeight: FontWeight.w700,
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
      color: _accountLine.withValues(alpha: 0.8),
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
            color: _accountDangerSoft.withValues(alpha: 0.9),
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
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          highlightColor: _accountTeal.withValues(alpha: 0.08),
          splashColor: _accountTeal.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _accountLineStrong),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accountIconBgTop, _accountIconBgBottom],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x144C8ED4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: _accountTealStrong),
          ),
        ),
      ),
    );
  }
}

class _AccountDetailsSheet extends StatelessWidget {
  const _AccountDetailsSheet({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(30),
            bottom: Radius.circular(22),
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.98)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.96),
              _accountSurfaceSoft.withValues(alpha: 0.94),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33275B8C),
              blurRadius: 42,
              offset: Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 54,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _accountTealStrong.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.brightness_1_rounded,
                              color: _accountGold,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'magic sora',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _accountTealStrong,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.8,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '계정 상세',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: _accountText,
                                fontSize: 24,
                                height: 1.06,
                              ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: _accountTealStrong,
                      backgroundColor: _accountSurfaceLavender,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: _accountLineStrong),
                      ),
                    ),
                    child: const Text('닫기'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.radio_button_checked_rounded,
                label: '로그인 방식',
                subtitle: '현재 연결 수단',
                value: user.isDemo ? '데모 세션' : '${user.loginProvider} 로그인',
              ),
              const _DetailDivider(),
              _DetailRow(
                icon: Icons.alternate_email_rounded,
                label: '이메일',
                subtitle: '동기화 계정',
                value: _accountEmail(user),
              ),
              const _DetailDivider(),
              _DetailRow(
                icon: Icons.blur_circular_rounded,
                label: '기록 상태',
                subtitle: '질문기록 보관',
                value: user.isDemo ? '임시 보관 중' : '연결 유지 중',
              ),
              const _DetailDivider(),
              const _DetailRow(
                icon: Icons.numbers_rounded,
                label: '앱 버전',
                subtitle: '현재 빌드',
                value: 'v1.0',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_accountIconBgTop, _accountIconBgBottom],
              ),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _accountLineStrong),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x124C8ED4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: _accountTealStrong, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _accountText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _accountTextMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
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
      color: _accountLine.withValues(alpha: 0.82),
      indent: 52,
    );
  }
}

String _accountEmail(AppUser user) {
  final email = user.email?.trim() ?? '';
  if (email.isNotEmpty) {
    return email;
  }
  return user.isDemo ? 'demo@magicsora.app' : '등록된 이메일 없음';
}
