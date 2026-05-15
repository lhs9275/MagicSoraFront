import 'package:flutter/material.dart';

import '../../core/widgets/ocean_shell_widgets.dart';
import '../auth/login_screen.dart';
import '../auth/sign_up_screen.dart';
import '../home/magic_conch_home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const _imageAsset = 'assets/images/magic_sora_main.png';
  static const _designSize = Size(1735, 907);

  void _openSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
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
        useSafeArea: false,
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: _designSize.width,
              height: _designSize.height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(_imageAsset, fit: BoxFit.fill),
                  _MenuHitArea(
                    label: '회원가입',
                    rect: const Rect.fromLTWH(796, 224, 726, 171),
                    onTap: () => _openSignUp(context),
                  ),
                  _MenuHitArea(
                    label: '로그인으로 사용',
                    rect: const Rect.fromLTWH(796, 411, 726, 171),
                    onTap: () => _openLogin(context),
                  ),
                  _MenuHitArea(
                    label: '비로그인으로 사용',
                    rect: const Rect.fromLTWH(802, 600, 720, 171),
                    onTap: () => _openGuest(context),
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

class _MenuHitArea extends StatelessWidget {
  const _MenuHitArea({
    required this.label,
    required this.rect,
    required this.onTap,
  });

  final String label;
  final Rect rect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: Semantics(
        label: label,
        button: true,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(96),
          child: InkWell(
            borderRadius: BorderRadius.circular(96),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
