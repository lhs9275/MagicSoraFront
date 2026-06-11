import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

/// 앱 전역 테마와 첫 진입 화면을 정의하는 최상위 위젯이다.
class DebateApp extends StatelessWidget {
  const DebateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Sora Debate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainMenuScreen(),
    );
  }
}
