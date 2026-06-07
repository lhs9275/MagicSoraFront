class BffConfig {
  const BffConfig._();

  static const _baseUrlFromEnvironment = String.fromEnvironment('BFF_BASE_URL');
  static const _kakaoLoginPathFromEnvironment = String.fromEnvironment(
    'BFF_KAKAO_LOGIN_PATH',
    defaultValue: '/auth/kakao/login',
  );

  static String get baseUrl => _baseUrlFromEnvironment.trim();
  static String get kakaoLoginPath =>
      _normalizePath(_kakaoLoginPathFromEnvironment);

  static bool get hasBaseUrl => baseUrl.isNotEmpty;

  static Uri kakaoLoginUri() {
    final parsedBaseUrl = Uri.parse(baseUrl);
    return parsedBaseUrl.resolve(kakaoLoginPath);
  }

  static String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '/auth/kakao/login';
    }

    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
