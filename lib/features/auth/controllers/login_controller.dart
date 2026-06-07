import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/login_result.dart';

/// 로그인 화면에서 사용하는 입력 검증과 임시 인증 흐름을 담당한다.
class LoginController {
  /// 아이디 입력값이 비어 있는지 확인한다.
  String? validateIdentifier(String? value) {
    final identifier = value?.trim() ?? '';

    if (identifier.isEmpty) {
      return '아이디를 입력해주세요.';
    }

    return null;
  }

  /// 이메일 형식이 최소한 맞는지 확인한다.
  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }

    if (!email.contains('@') || !email.contains('.')) {
      return '올바른 이메일 형식을 입력해주세요.';
    }

    return null;
  }

  /// 비밀번호 길이를 검사해 너무 짧은 입력을 막는다.
  String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return '비밀번호를 입력해주세요.';
    }

    if (password.length < 8) {
      return '비밀번호는 8자 이상이어야 합니다.';
    }

    return null;
  }

  /// 실제 인증 API가 연결되기 전까지는 형식 검증 후 데모 접근을 허용한다.
  Future<LoginResult> submitLogin({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return LoginResult(
      isSuccess: true,
      message: '$email 계정으로 데모 세션에 진입합니다.',
      user: AppUser.demo(nickname: 'Sora Demo', email: email),
    );
  }
}
