import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/text_scale_scope.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/widgets/token_auto_refresh_scope.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';
import 'package:magicsorafront/features/main_menu/presentation/screens/main_menu_screen.dart';

// 인증 서버가 붙지 않을 때 홈으로 바로 떨어지게 하는 디버그 플래그.
// 실제 로그인 흐름을 다시 쓰려면 false 로 둔다.
const bool _kDebugSkipLogin = false;

/// 앱 전역 테마와 첫 진입 화면을 정의하는 최상위 위젯이다.
class DebateApp extends StatelessWidget {
  const DebateApp({super.key, this.initialSession});

  final AuthSession? initialSession;

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();
    return MaterialApp(
      title: 'Magic Sora Debate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      navigatorKey: navigatorKey,
      builder: (context, child) {
        return TokenAutoRefreshScope(
          child: TextScaleScope(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: _AuthRootGate(
        navigatorKey: navigatorKey,
        initialSession: initialSession,
      ),
    );
  }
}

/// 세션 상태를 구독해 첫 화면을 정하고, 세션이 사라지면
/// 위에 쌓인 라우트를 모두 비워 로그인 화면으로 돌려보낸다.
class _AuthRootGate extends StatefulWidget {
  const _AuthRootGate({
    required this.navigatorKey,
    required this.initialSession,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final AuthSession? initialSession;

  @override
  State<_AuthRootGate> createState() => _AuthRootGateState();
}

class _AuthRootGateState extends State<_AuthRootGate> {
  late final AuthSessionStore _sessionStore;
  AuthSession? _lastObservedSession;

  @override
  void initState() {
    super.initState();
    _sessionStore = AuthSessionStore.instance;
    _lastObservedSession =
        _sessionStore.sessionListenable.value ?? widget.initialSession;
    if (widget.initialSession != null &&
        _sessionStore.sessionListenable.value == null) {
      _sessionStore.sessionListenable.value = widget.initialSession;
    }
    _sessionStore.sessionListenable.addListener(_handleSessionChanged);
  }

  @override
  void dispose() {
    _sessionStore.sessionListenable.removeListener(_handleSessionChanged);
    super.dispose();
  }

  void _handleSessionChanged() {
    final next = _sessionStore.sessionListenable.value;
    final wasLoggedIn = _lastObservedSession != null;
    _lastObservedSession = next;

    if (next == null && wasLoggedIn) {
      // 세션이 사라졌다 — 어디서 호출됐든 (logout, refresh 실패) 무조건 로그인으로.
      final navigator = widget.navigatorKey.currentState;
      if (navigator != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainMenuScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthSession?>(
      valueListenable: _sessionStore.sessionListenable,
      builder: (context, session, _) {
        if (_kDebugSkipLogin || session != null) {
          return MagicConchHomeScreen(user: session?.user);
        }
        return const MainMenuScreen();
      },
    );
  }
}
