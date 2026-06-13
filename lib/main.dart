import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/app/app.dart';
import 'package:magicsorafront/core/config/kakao_config.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_boot_splash.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootGate());
}

class _BootGate extends StatefulWidget {
  const _BootGate();

  @override
  State<_BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<_BootGate> {
  bool _isReady = false;
  AuthSession? _restoredSession;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await KakaoConfig.initialize();

    if (KakaoConfig.hasAnyAppKey) {
      KakaoSdk.init(
        nativeAppKey: KakaoConfig.nativeAppKey.isEmpty
            ? null
            : KakaoConfig.nativeAppKey,
        javaScriptAppKey: KakaoConfig.javaScriptAppKey.isEmpty
            ? null
            : KakaoConfig.javaScriptAppKey,
        loggingEnabled: true,
      );
      debugPrint(
        '[Kakao] init: nativeAppKey=${KakaoConfig.nativeAppKey.isNotEmpty}, '
        'javaScriptAppKey=${KakaoConfig.javaScriptAppKey.isNotEmpty} '
        '(len=${KakaoConfig.javaScriptAppKey.length})',
      );
    } else {
      debugPrint('[Kakao] init skipped: no app keys provided');
    }

    AuthSession? restored;
    try {
      restored = await AuthSessionStore.instance.loadSession();
    } catch (error) {
      debugPrint('[Auth] failed to restore session: $error');
      restored = null;
    }
    if (restored != null && restored.accessToken.trim().isEmpty) {
      restored = null;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _restoredSession = restored;
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return DebateApp(initialSession: _restoredSession);
    }

    return MaterialApp(
      title: 'Magic Sora Debate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppBootSplash(),
    );
  }
}
