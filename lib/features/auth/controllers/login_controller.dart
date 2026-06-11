import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/login_result.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';

/// 로그인 화면에서 사용하는 입력 검증과 인증 흐름을 담당한다.
class LoginController {
  LoginController({
    BffAuthService? bffAuthService,
    AuthSessionStore? authSessionStore,
  }) : _bffAuthService = bffAuthService ?? BffAuthService(),
       _authSessionStore = authSessionStore ?? AuthSessionStore.instance;

  final BffAuthService _bffAuthService;
  final AuthSessionStore _authSessionStore;

  String? validateIdentifier(String? value) {
    final identifier = value?.trim() ?? '';

    if (identifier.isEmpty) {
      return '아이디를 입력해주세요.';
    }

    return null;
  }

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

  /// 가이드 1.2: POST /mapi/auth/token으로 access/refresh 토큰을 발급받는다.
  Future<LoginResult> submitLogin({
    required String email,
    required String password,
  }) async {
    final cleanedEmail = email.trim();
    final fallbackUser = AppUser(
      nickname: _nicknameFromEmail(cleanedEmail),
      loginProvider: 'EMAIL',
      email: cleanedEmail,
    );

    try {
      final session = await _bffAuthService.loginWithEmailPassword(
        email: cleanedEmail,
        password: password,
        fallbackUser: fallbackUser,
      );
      await _authSessionStore.saveSession(session);

      return LoginResult(
        isSuccess: true,
        message: '${session.user.nickname}님, 로그인에 성공했습니다.',
        user: session.user,
        session: session,
      );
    } on BffAuthException catch (error) {
      return LoginResult(
        isSuccess: false,
        message: _messageForLoginError(error),
      );
    } catch (_) {
      return const LoginResult(
        isSuccess: false,
        message: '로그인 중 알 수 없는 오류가 발생했습니다.',
      );
    }
  }

  String _messageForLoginError(BffAuthException error) {
    final statusCode = error.statusCode;
    if (statusCode == 401) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }
    if (statusCode == 400) {
      return '입력값이 올바르지 않습니다. 다시 확인해주세요.';
    }
    return error.message;
  }

  String _nicknameFromEmail(String email) {
    final prefix = email.split('@').first.trim();
    return prefix.isEmpty ? '사용자' : prefix;
  }
}
