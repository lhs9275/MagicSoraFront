import 'package:magicsorafront/features/auth/models/app_user.dart';

/// BFF가 발급한 토큰과 현재 로그인 사용자 정보를 함께 보관한다.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: (json['accessToken'] as String? ?? '').trim(),
      refreshToken: (json['refreshToken'] as String?)?.trim(),
      user: AppUser.fromJson(_asStringKeyedMap(json['user'])),
    );
  }

  final String accessToken;
  final String? refreshToken;
  final AppUser user;

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
    };
  }

  static Map<String, dynamic> _asStringKeyedMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(key.toString(), nestedValue),
      );
    }

    return const {};
  }
}
