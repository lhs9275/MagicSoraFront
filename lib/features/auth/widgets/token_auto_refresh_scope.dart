import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';

/// 자식 위젯 트리가 살아있는 동안 access token 을 자동으로 갱신해주는 스코프.
///
/// - 마운트 직후 1회 proactive refresh.
/// - [refreshInterval] 마다 주기적으로 refresh.
/// - 앱이 백그라운드에서 다시 활성화되면(`AppLifecycleState.resumed`) refresh.
///
/// 모든 refresh 호출은 [BffAuthService.refreshSession] 의 single-flight 가드 덕에
/// 중복 네트워크 요청 없이 안전하다. 캐시된 세션이 없으면(refreshToken 없음)
/// refreshSession 이 빠르게 null 을 반환하므로 비용도 거의 없다.
class TokenAutoRefreshScope extends StatefulWidget {
  const TokenAutoRefreshScope({
    required this.child,
    super.key,
    this.refreshInterval = const Duration(minutes: 25),
    this.authService,
    this.sessionStore,
  });

  final Widget child;
  final Duration refreshInterval;
  final BffAuthService? authService;
  final AuthSessionStore? sessionStore;

  @override
  State<TokenAutoRefreshScope> createState() => _TokenAutoRefreshScopeState();
}

class _TokenAutoRefreshScopeState extends State<TokenAutoRefreshScope>
    with WidgetsBindingObserver {
  late final BffAuthService _authService;
  late final AuthSessionStore _sessionStore;
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    _sessionStore = widget.sessionStore ?? AuthSessionStore.instance;
    _authService =
        widget.authService ?? BffAuthService(sessionStore: _sessionStore);

    WidgetsBinding.instance.addObserver(this);
    _scheduleRefresh();
    unawaited(_refreshIfPossible());
  }

  void _scheduleRefresh() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      widget.refreshInterval,
      (_) => unawaited(_refreshIfPossible()),
    );
  }

  Future<void> _refreshIfPossible() async {
    // 캐시된 세션이 없거나 refresh token이 없으면 refreshSession이 즉시 null 을 돌려준다.
    // 결과는 무시 — 실패 시 다음 401 응답에서 _withTokenRefresh 가 한 번 더 시도한다.
    final session = await _sessionStore.loadSession();
    if (session == null || (session.refreshToken?.trim().isEmpty ?? true)) {
      debugPrint('[TokenAutoRefresh] skip: no session/refresh token');
      return;
    }
    debugPrint('[TokenAutoRefresh] attempting refresh');
    try {
      final refreshed = await _authService.refreshSession();
      debugPrint(
        '[TokenAutoRefresh] result: ${refreshed != null ? 'success' : 'failed/null'}',
      );
    } catch (error) {
      debugPrint('[TokenAutoRefresh] error: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshIfPossible());
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
