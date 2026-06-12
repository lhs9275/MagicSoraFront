import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

// 인증 서버가 붙지 않을 때 홈으로 바로 떨어지게 하는 디버그 플래그.
// 실제 로그인 흐름을 다시 쓰려면 false 로 둔다.
const bool _kDebugSkipLogin = true;

/// 앱 전역 테마와 첫 진입 화면을 정의하는 최상위 위젯이다.
class DebateApp extends StatelessWidget {
  const DebateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Sora Debate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: _kDebugSkipLogin
          ? const MagicConchHomeScreen()
          : const MainMenuScreen(),
    );
  }
}
