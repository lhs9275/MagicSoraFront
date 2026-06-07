import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';

/// 로그인 시도 결과를 화면으로 전달하기 위한 단순 모델이다.
class LoginResult {
  const LoginResult({
    required this.isSuccess,
    required this.message,
    this.user,
    this.session,
  });

  final bool isSuccess;
  final String message;
  final AppUser? user;
  final AuthSession? session;
}
