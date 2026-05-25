import 'package:magicsorafront/features/auth/models/sign_up_result.dart';

class SignUpController {
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

  String? validatePasswordConfirm(String? value, String password) {
    final passwordConfirm = value ?? '';

    if (passwordConfirm.isEmpty) {
      return '비밀번호 확인을 입력해주세요.';
    }

    if (passwordConfirm != password) {
      return '비밀번호가 일치하지 않습니다.';
    }

    return null;
  }

  Future<SignUpResult> submitSignUp({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // TODO: 회원가입 API가 준비되면 이곳에서 실제 서버 연동으로 교체한다.
    return SignUpResult(
      isSuccess: true,
      message: '$email 계정이 임시로 생성되었습니다. 로그인 화면으로 이동합니다.',
    );
  }
}
