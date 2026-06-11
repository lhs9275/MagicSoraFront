import 'package:magicsorafront/features/auth/models/sign_up_result.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';

class SignUpController {
  SignUpController({BffAuthService? bffAuthService})
    : _bffAuthService = bffAuthService ?? BffAuthService();

  final BffAuthService _bffAuthService;

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

  String? validateName(String? value) {
    final name = value?.trim() ?? '';

    if (name.isEmpty) {
      return '이름을 입력해주세요.';
    }

    if (name.length > 30) {
      return '이름은 30자 이내로 입력해주세요.';
    }

    return null;
  }

  /// 가이드 1.1: POST /user (form-encoded) — email/password/name. 201 응답.
  Future<SignUpResult> submitSignUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final cleanedEmail = email.trim();
    final cleanedName = name.trim();

    try {
      await _bffAuthService.signUpWithEmail(
        email: cleanedEmail,
        password: password,
        name: cleanedName,
      );
      return SignUpResult(
        isSuccess: true,
        message: '$cleanedEmail 계정이 생성되었습니다. 로그인 화면으로 이동합니다.',
      );
    } on BffAuthException catch (error) {
      return SignUpResult(
        isSuccess: false,
        message: _messageForSignUpError(error),
      );
    } catch (_) {
      return const SignUpResult(
        isSuccess: false,
        message: '회원가입 중 알 수 없는 오류가 발생했습니다.',
      );
    }
  }

  String _messageForSignUpError(BffAuthException error) {
    final statusCode = error.statusCode;
    if (statusCode == 409) {
      return '이미 가입된 이메일입니다. 다른 이메일을 사용해주세요.';
    }
    if (statusCode == 400) {
      return '입력값이 올바르지 않습니다. 다시 확인해주세요.';
    }
    return error.message;
  }
}
