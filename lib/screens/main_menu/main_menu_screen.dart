import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/sign_up_screen.dart';
import '../home/magic_conch_home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const _conchAsset = 'assets/images/magic_conch.png';
  static const _kakaoLoginAsset = 'lib/kakao_login_medium_wide.png';

  void _openSignUp(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SignUpScreen()));
  }

  void _openLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
  }

  void _openGuest(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MagicConchHomeScreen()),
    );
  }

  void _startKakaoLogin(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('카카오 로그인은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 720;
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final topPadding = isCompact ? 14.0 : 28.0;
            const bottomPadding = 28.0;
            final minHeight =
                constraints.maxHeight - topPadding - bottomPadding;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight > 0 ? minHeight : 0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isCompact
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _BrandBlock(isCompact: true),
                              const SizedBox(height: 22),
                              _AuthActionPanel(
                                onKakaoLogin: () => _startKakaoLogin(context),
                                onSignUp: () => _openSignUp(context),
                                onLogin: () => _openLogin(context),
                                onGuest: () => _openGuest(context),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(
                                child: _BrandBlock(isCompact: false),
                              ),
                              const SizedBox(width: 38),
                              SizedBox(
                                width: 440,
                                child: _AuthActionPanel(
                                  onKakaoLogin: () => _startKakaoLogin(context),
                                  onSignUp: () => _openSignUp(context),
                                  onLogin: () => _openLogin(context),
                                  onGuest: () => _openGuest(context),
                                ),
                              ),
                            ],
                          ),
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final textAlign = isCompact ? TextAlign.center : TextAlign.left;
    final crossAxisAlignment = isCompact
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 500.0;
        final imageWidth = isCompact
            ? (availableWidth < 270 ? availableWidth : 270.0)
            : (availableWidth < 500 ? availableWidth : 500.0);
        final imageHeight = imageWidth * 196 / 270;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(
              'magic sora',
              textAlign: textAlign,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppTheme.primaryDark,
                fontSize: isCompact ? 42 : 58,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '질문하고, 토론하고, 기록하는 마법의 소라고동',
              textAlign: textAlign,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: isCompact ? 16 : 28),
            Align(
              alignment: isCompact ? Alignment.center : Alignment.centerLeft,
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
                child: Image.asset(
                  MainMenuScreen._conchAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuthActionPanel extends StatelessWidget {
  const _AuthActionPanel({
    required this.onKakaoLogin,
    required this.onSignUp,
    required this.onLogin,
    required this.onGuest,
  });

  final VoidCallback onKakaoLogin;
  final VoidCallback onSignUp;
  final VoidCallback onLogin;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 340;
        final panelPadding = EdgeInsets.fromLTRB(
          isTight ? 16 : 20,
          isTight ? 20 : 22,
          isTight ? 16 : 20,
          20,
        );

        return OceanPanel(
          padding: panelPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('시작하기', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                '계정으로 기록을 저장하거나 바로 데모를 둘러보세요.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 22),
              _KakaoLoginButton(onPressed: onKakaoLogin),
              const SizedBox(height: 12),
              _GeneralLoginButton(onPressed: onLogin),
              const SizedBox(height: 18),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      '계정이 없나요?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(onPressed: onSignUp, child: const Text('회원가입')),
                  ],
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: onGuest,
                  child: const Text('계정 없이 둘러보기'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.onPressed});

  static const _baseWidth = 300.0;
  static const _baseHeight = 45.0;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : _baseWidth;
          final buttonWidth = availableWidth < _baseWidth
              ? availableWidth
              : _baseWidth;

          return Semantics(
            label: '카카오로 시작하기',
            button: true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPressed,
                child: Image.asset(
                  MainMenuScreen._kakaoLoginAsset,
                  width: buttonWidth,
                  height: _baseHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GeneralLoginButton extends StatelessWidget {
  const _GeneralLoginButton({required this.onPressed});

  static const _baseWidth = 300.0;
  static const _baseHeight = 45.0;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : _baseWidth;
          final buttonWidth = availableWidth < _baseWidth
              ? availableWidth
              : _baseWidth;

          return Material(
            color: const Color(0xFFDFF9F5),
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            shadowColor: AppTheme.primaryDark.withValues(alpha: 0.16),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onPressed,
              child: SizedBox(
                width: buttonWidth,
                height: _baseHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.74),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_lock_rounded,
                        size: buttonWidth < 290 ? 18 : 19,
                        color: AppTheme.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '일반 로그인',
                        style: TextStyle(
                          color: AppTheme.primaryDark,
                          fontSize: buttonWidth < 290 ? 14 : 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
