import 'package:flutter/material.dart';
import 'package:magicsorafront/core/navigation/app_page_routes.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_snack_bar.dart';
import 'package:magicsorafront/core/widgets/brand_wordmark.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/controllers/kakao_auth_controller.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final _kakaoAuthController = KakaoAuthController();

  bool _isKakaoSubmitting = false;

  Future<void> _submitKakaoLogin() async {
    if (_isKakaoSubmitting) {
      return;
    }

    setState(() {
      _isKakaoSubmitting = true;
    });

    final result = await _kakaoAuthController.submitKakaoLogin();

    if (!mounted) {
      return;
    }

    setState(() {
      _isKakaoSubmitting = false;
    });

    showAppSnackBar(context, result.message);

    if (!result.isSuccess) {
      return;
    }

    Navigator.of(context).pushReplacement(
      fadeSlideRoute<void>(
        MagicConchHomeScreen(user: result.user ?? AppUser.fallback),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final topPadding = constraints.maxHeight < 640 ? 112.0 : 172.0;
            final bottomPadding = constraints.maxHeight < 640 ? 72.0 : 98.0;
            final loginBottomPadding = bottomPadding + 14;
            final brandAlignment = constraints.maxHeight < 640
                ? const Alignment(0, -0.3)
                : const Alignment(0, -0.42);
            const loginAreaHeight = 56.0;
            final minHeight =
                constraints.maxHeight -
                topPadding -
                bottomPadding -
                loginAreaHeight;

            return Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                0,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        topPadding,
                        0,
                        bottomPadding + loginAreaHeight,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: minHeight > 0 ? minHeight : 0,
                        ),
                        child: Align(
                          alignment: brandAlignment,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 480),
                            child: const _BrandBlock(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: loginBottomPadding),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: _KakaoLoginButton(
                          isLoading: _isKakaoSubmitting,
                          onPressed: _submitKakaoLogin,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 340),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          child: Transform.scale(scale: 0.96 + progress * 0.04, child: child),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isTight = constraints.maxWidth < 340;
          final targetConchWidth = isTight ? 276.0 : 332.0;
          final availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : targetConchWidth;
          final conchWidth = availableWidth < targetConchWidth
              ? availableWidth
              : targetConchWidth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: Offset(0, isTight ? -38 : -52),
                child: BrandWordmark(fontSize: isTight ? 56 : 72),
              ),
              const SizedBox(height: 28),
              Image.asset(
                'assets/images/brand/magic_conch.png',
                width: conchWidth,
                height: conchWidth * 0.72,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
              Text(
                '질문하고, 토론하고, 기록하는 마법의 소라고동',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KakaoLoginButton extends StatefulWidget {
  const _KakaoLoginButton({required this.isLoading, required this.onPressed});

  static const _assetPath = 'assets/images/auth/kakao_login_medium_wide.png';

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  State<_KakaoLoginButton> createState() => _KakaoLoginButtonState();
}

class _KakaoLoginButtonState extends State<_KakaoLoginButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value || widget.isLoading) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  void didUpdateWidget(covariant _KakaoLoginButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading && _isPressed) {
      _isPressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '카카오 로그인',
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          onTap: widget.isLoading ? null : widget.onPressed,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < 300
                  ? constraints.maxWidth
                  : 300.0;

              return AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: widget.isLoading ? 0.62 : 1,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  curve: Curves.easeOutCubic,
                  scale: _isPressed ? 0.98 : 1,
                  child: SizedBox(
                    width: width,
                    height: 45,
                    child: Image.asset(
                      _KakaoLoginButton._assetPath,
                      width: width,
                      height: 45,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
