import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            const topPadding = 28.0;
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
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _BrandBlock(),
                        const SizedBox(height: 22),
                        const _AuthActionPanel(),
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
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 340;
        final targetConchWidth = isTight ? 252.0 : 296.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : targetConchWidth;
        final conchWidth = availableWidth < targetConchWidth
            ? availableWidth
            : targetConchWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }
}

class _AuthActionPanel extends StatelessWidget {
  const _AuthActionPanel();

  @override
  Widget build(BuildContext context) {
    return const _InlineLoginPanel();
  }
}

class _InlineLoginPanel extends StatefulWidget {
  const _InlineLoginPanel();

  @override
  State<_InlineLoginPanel> createState() => _InlineLoginPanelState();
}

class _InlineLoginPanelState extends State<_InlineLoginPanel> {
  void _submitKakaoLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('카카오 로그인은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '시작하기',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _KakaoLoginButton(onPressed: _submitKakaoLogin),
          ),
        ],
      ),
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const kakaoYellow = Color(0xFFFEE500);
    const kakaoText = Color(0xFF191600);

    return Semantics(
      label: '카카오 로그인',
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kakaoYellow,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onPressed,
            child: SizedBox(
              height: 58,
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: kakaoText,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      '카카오 로그인',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: kakaoText,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

