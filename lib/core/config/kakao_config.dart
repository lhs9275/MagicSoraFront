import 'package:flutter/services.dart';

class KakaoConfig {
  const KakaoConfig._();

  static const _channel = MethodChannel('magicsorafront/kakao_config');
  static const _nativeAppKeyFromEnvironment = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
  );
  static const _javaScriptAppKeyFromEnvironment = String.fromEnvironment(
    'KAKAO_JAVASCRIPT_APP_KEY',
  );

  static String _nativeAppKey = _nativeAppKeyFromEnvironment;
  static String _javaScriptAppKey = _javaScriptAppKeyFromEnvironment;

  static String get nativeAppKey => _nativeAppKey;
  static String get javaScriptAppKey => _javaScriptAppKey;

  static bool get hasNativeAppKey => nativeAppKey.isNotEmpty;
  static bool get hasAnyAppKey =>
      nativeAppKey.isNotEmpty || javaScriptAppKey.isNotEmpty;

  static Future<void> initialize() async {
    if (_nativeAppKey.isEmpty) {
      _nativeAppKey = await _loadNativeAppKeyFromPlatform();
    }
  }

  static Future<String> _loadNativeAppKeyFromPlatform() async {
    try {
      final nativeAppKey = await _channel.invokeMethod<String>(
        'getNativeAppKey',
      );
      return nativeAppKey?.trim() ?? '';
    } on MissingPluginException {
      return '';
    } on PlatformException {
      return '';
    }
  }
}
