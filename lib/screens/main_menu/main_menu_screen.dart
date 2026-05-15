import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/sign_up_screen.dart';
import '../home/magic_conch_home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const _conchAsset = 'assets/images/magic_conch.png';

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
            width: isCompact ? 270 : 500,
            height: isCompact ? 196 : 360,
            child: Image.asset(MainMenuScreen._conchAsset, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

class _AuthActionPanel extends StatelessWidget {
  const _AuthActionPanel({
    required this.onSignUp,
    required this.onLogin,
    required this.onGuest,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogin;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
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
          OceanPillButton(
            label: '회원가입',
            icon: Icons.star_rounded,
            backgroundColor: AppTheme.shellPink,
            onPressed: onSignUp,
          ),
          const SizedBox(height: 12),
          OceanPillButton(
            label: '로그인으로 사용',
            icon: Icons.login_rounded,
            backgroundColor: AppTheme.shellPurple,
            onPressed: onLogin,
          ),
          const SizedBox(height: 12),
          OceanPillButton(
            label: '비로그인으로 사용',
            icon: Icons.visibility_rounded,
            backgroundColor: AppTheme.primaryLight,
            onPressed: onGuest,
          ),
        ],
      ),
    );
  }
}
