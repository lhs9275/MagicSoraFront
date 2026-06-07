/// 앱 화면에서 사용하는 최소 사용자 세션 정보다.
class AppUser {
  const AppUser({
    required this.nickname,
    required this.loginProvider,
    this.email,
    this.profileImageUrl,
    this.isDemo = false,
  });

  static const fallback = AppUser(
    nickname: 'Sora Demo',
    email: 'demo@magicsora.app',
    loginProvider: '데모',
    isDemo: true,
  );

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final isDemo = json['isDemo'] == true;

    return AppUser(
      nickname: _cleanOrFallback(
        json['nickname']?.toString(),
        isDemo ? 'Sora Demo' : '사용자',
      ),
      email: _cleanOptional(json['email']?.toString()),
      profileImageUrl: _cleanOptional(json['profileImageUrl']?.toString()),
      loginProvider: _cleanOrFallback(
        json['loginProvider']?.toString(),
        isDemo ? '데모' : '일반',
      ),
      isDemo: isDemo,
    );
  }

  factory AppUser.demo({String? nickname, String? email}) {
    return AppUser(
      nickname: _cleanOrFallback(nickname, 'Sora Demo'),
      email: _cleanOptional(email),
      loginProvider: '데모',
      isDemo: true,
    );
  }

  factory AppUser.kakao({
    required String? nickname,
    required String? email,
    required String? profileImageUrl,
  }) {
    return AppUser(
      nickname: _cleanOrFallback(nickname, '카카오 사용자'),
      email: _cleanOptional(email),
      profileImageUrl: _cleanOptional(profileImageUrl),
      loginProvider: '카카오',
    );
  }

  final String nickname;
  final String? email;
  final String? profileImageUrl;
  final String loginProvider;
  final bool isDemo;

  Map<String, dynamic> toJson() {
    return {
      'nickname': nickname,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'loginProvider': loginProvider,
      'isDemo': isDemo,
    };
  }

  String get accountLabel {
    final rawEmail = email?.trim() ?? '';
    if (rawEmail.isNotEmpty) {
      return rawEmail;
    }

    return '$loginProvider 계정';
  }

  static String? _cleanOptional(String? value) {
    final cleaned = value?.trim() ?? '';
    return cleaned.isEmpty ? null : cleaned;
  }

  static String _cleanOrFallback(String? value, String fallback) {
    return _cleanOptional(value) ?? fallback;
  }
}
