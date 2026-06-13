import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/app/app.dart';
import 'package:magicsorafront/core/config/kakao_config.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_boot_splash.dart';

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

    if (!mounted) {
      return;
    }
    setState(() {
      _isReady = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isReady) {
      return const DebateApp();
    }

    return MaterialApp(
      title: 'Magic Sora Debate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppBootSplash(),
    );
  }
}
