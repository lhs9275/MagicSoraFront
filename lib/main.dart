import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/app/app.dart';
import 'package:magicsorafront/core/config/kakao_config.dart';

Future<void> main() async {
  // Flutter 바인딩을 먼저 초기화해 앱 전역 설정이 필요한 경우를 대비한다.
  WidgetsFlutterBinding.ensureInitialized();
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

  runApp(const DebateApp());
}
