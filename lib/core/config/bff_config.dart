class BffConfig {
  const BffConfig._();

  static const _baseUrlFromEnvironment = String.fromEnvironment(
    'BFF_BASE_URL',
    defaultValue: 'https://bff.noctide.dev',
  );
  static const _kakaoLoginPathFromEnvironment = String.fromEnvironment(
    'BFF_KAKAO_LOGIN_PATH',
    defaultValue: '/mapi/auth/kakao',
  );

  static String get baseUrl => _baseUrlFromEnvironment.trim();
  static String get kakaoLoginPath =>
      _normalizePath(_kakaoLoginPathFromEnvironment);

  static bool get hasBaseUrl => baseUrl.isNotEmpty;

  static Uri kakaoLoginUri() {
    return apiUri(kakaoLoginPath);
  }

  static Uri apiUri(
    String path, {
    Map<String, Object?> queryParameters = const {},
  }) {
    final parsedBaseUrl = Uri.parse(baseUrl);
    final resolved = parsedBaseUrl.resolve(_normalizePath(path));

    final cleanedQueryParameters = <String, String>{};
    for (final entry in queryParameters.entries) {
      final value = entry.value;
      if (value == null) {
        continue;
      }
      cleanedQueryParameters[entry.key] = value.toString();
    }

    if (cleanedQueryParameters.isEmpty) {
      return resolved;
    }

    return resolved.replace(queryParameters: cleanedQueryParameters);
  }

  static String _normalizePath(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '/mapi/auth/kakao';
    }

    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}
