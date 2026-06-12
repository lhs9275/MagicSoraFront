import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/account/presentation/screens/app_info_screen.dart';
import 'package:magicsorafront/features/account/presentation/screens/help_screen.dart';
import 'package:magicsorafront/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:magicsorafront/features/account/presentation/screens/text_scale_settings_screen.dart';
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
const _accountIconBgTop = Color(0xFFF9FBFF);
const _accountIconBgBottom = Color(0xFFEBF1FF);
const _accountDanger = Color(0xFFC75E6E);
const _accountDangerSoft = Color(0xFFFFF5F6);

/// 로그인한 사용자의 계정 정보와 프로필 설정 진입점을 보여주는 화면이다.
class AccountProfileScreen extends StatefulWidget {
  const AccountProfileScreen({super.key, AppUser? user, this.onUserChanged})
    : user = user ?? AppUser.fallback;

  final AppUser user;
  final ValueChanged<AppUser>? onUserChanged;

  @override
  State<AccountProfileScreen> createState() => _AccountProfileScreenState();
}

class _AccountProfileScreenState extends State<AccountProfileScreen> {
  late AppUser _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
    _hydrateUser();
  }

  Future<void> _hydrateUser() async {
    final hydratedUser = await AuthSessionStore.instance.hydrateUser(_user);
    if (!mounted) {
      return;
    }

    setState(() {
      _user = hydratedUser;
    });
    widget.onUserChanged?.call(hydratedUser);
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label은 아직 준비 중입니다.')));
  }

  void _handleMenuTap(BuildContext context, String label) {
    if (label == '도움말') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const HelpScreen()),
      );
      return;
    }
    if (label == '알림 설정') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const NotificationSettingsScreen(),
        ),
      );
      return;
    }
    if (label == '글자 크기') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const TextScaleSettingsScreen(),
        ),
      );
      return;
    }
    if (label == '앱 정보') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const AppInfoScreen()),
      );
      return;
    }
    _showComingSoon(context, label);
  }

  Future<void> _openNicknameSetting() async {
    final nextNickname = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _NicknameSettingDialog(initialNickname: _user.nickname);
      },
    );

    if (nextNickname == null || nextNickname == _user.nickname) {
      return;
    }

    final updatedUser = await AuthSessionStore.instance.saveNickname(
      nickname: nextNickname,
      fallbackUser: _user,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _user = updatedUser;
    });
    widget.onUserChanged?.call(updatedUser);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('닉네임을 저장했습니다.')));
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (_user.loginProvider == '카카오' && !_user.isDemo) {
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
                      const _ProfileTopBar(),
                      const SizedBox(height: 18),
                      _ProfileHero(user: _user),
                      const SizedBox(height: 14),
                      _ProfileMenuSection(
                        currentNickname: _user.nickname,
                        onNicknameTap: _openNicknameSetting,
                        onMenuTap: (label) => _handleMenuTap(context, label),
                      ),
                      const SizedBox(height: 16),
                      _LogoutButton(onPressed: () => _handleLogout(context)),
                      const SizedBox(height: 16),
                      const _AppVersionFootnote(version: 'v1.0.0'),
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
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    _ProfileAvatar(imageUrl: user.profileImageUrl),
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
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: _accountText,
                                    fontSize: 31,
                                    height: 1.04,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            _HeroStatusPill(
                              label: user.isDemo
                                  ? '데모 세션'
                                  : '${user.loginProvider} 로그인됨',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _HeroAccountMeta(user: user),
              ],
            ),
          ),
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

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({
    required this.currentNickname,
    required this.onNicknameTap,
    required this.onMenuTap,
  });

  final String currentNickname;
  final VoidCallback onNicknameTap;
  final ValueChanged<String> onMenuTap;

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
            child: _PanelHeader(title: '설정'),
          ),
          _ProfileMenuTile(
            icon: Icons.badge_outlined,
            title: '닉네임 설정',
            subtitle: currentNickname,
            onTap: onNicknameTap,
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
            icon: Icons.text_fields_rounded,
            title: '글자 크기',
            subtitle: '읽기 편한 크기로',
            onTap: () => onMenuTap('글자 크기'),
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
            subtitle: '버전 · 약관 · 라이선스',
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

class _HeroAccountMeta extends StatelessWidget {
  const _HeroAccountMeta({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          _HeroMetaRow(
            icon: Icons.radio_button_checked_rounded,
            label: '로그인',
            value: user.isDemo ? '데모 세션' : '${user.loginProvider} 로그인',
          ),
          Divider(
            height: 18,
            color: _accountLine.withValues(alpha: 0.82),
            indent: 44,
          ),
          _HeroMetaRow(
            icon: Icons.alternate_email_rounded,
            label: '이메일',
            value: _accountEmail(user),
          ),
        ],
      ),
    );
  }
}

class _HeroMetaRow extends StatelessWidget {
  const _HeroMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_accountIconBgTop, _accountIconBgBottom],
            ),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: _accountLineStrong),
          ),
          child: Icon(icon, color: _accountTealStrong, size: 17),
        ),
        const SizedBox(width: 12),
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
          child: Align(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                maxLines: 1,
                softWrap: false,
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _accountText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppVersionFootnote extends StatelessWidget {
  const _AppVersionFootnote({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '앱 버전 $version',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _accountTextMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _NicknameSettingDialog extends StatefulWidget {
  const _NicknameSettingDialog({required this.initialNickname});

  final String initialNickname;

  @override
  State<_NicknameSettingDialog> createState() => _NicknameSettingDialogState();
}

class _NicknameSettingDialogState extends State<_NicknameSettingDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _errorText = '닉네임을 입력해주세요.';
      });
      return;
    }

    Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('닉네임 설정'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: '닉네임을 입력하세요',
          errorText: _errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        TextButton(onPressed: _submit, child: const Text('저장')),
      ],
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
