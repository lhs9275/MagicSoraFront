import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/core/config/kakao_config.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:magicsorafront/features/auth/models/login_result.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';

class KakaoAuthController {
  KakaoAuthController({AuthSessionStore? authSessionStore})
    : _authSessionStore = authSessionStore ?? AuthSessionStore.instance;

  final AuthSessionStore _authSessionStore;

  Future<LoginResult> submitKakaoLogin() async {
    if (!KakaoConfig.hasNativeAppKey) {
      return const LoginResult(
        isSuccess: false,
        message: '카카오 네이티브 앱 키를 설정한 뒤 다시 시도해주세요.',
      );
    }

    try {
      final token = await _login();
      if (token.accessToken.isEmpty) {
        return const LoginResult(
          isSuccess: false,
          message: '카카오 로그인 토큰을 받지 못했습니다.',
        );
      }

      final user = await _fetchKakaoUserOrFallback();
      final session = _createLocalSession(token: token, user: user);
      await _authSessionStore.saveSession(session);

      return LoginResult(
        isSuccess: true,
        message: '${session.user.nickname}님, 로그인에 성공했습니다.',
        user: session.user,
        session: session,
      );
    } catch (error) {
      return LoginResult(isSuccess: false, message: _messageFor(error));
    }
  }

  AuthSession _createLocalSession({
    required OAuthToken token,
    required AppUser user,
  }) {
    return AuthSession(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      user: user,
    );
  }

  Future<AppUser> _fetchKakaoUserOrFallback() async {
    try {
      final kakaoUser = await UserApi.instance.me();
      final account = kakaoUser.kakaoAccount;
      final profile = account?.profile;
      final profileImageUrl =
          profile?.profileImageUrl ?? profile?.thumbnailImageUrl;

      return AppUser.kakao(
        nickname: profile?.nickname,
        email: account?.email,
        profileImageUrl: profileImageUrl,
      );
    } catch (_) {
      return AppUser.kakao(nickname: null, email: null, profileImageUrl: null);
    }
  }

  Future<OAuthToken> _login() async {
    final isTalkAvailable = await isKakaoTalkInstalled();

    if (!isTalkAvailable) {
      return UserApi.instance.loginWithKakaoAccount();
    }

    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } catch (error) {
      if (_isUserCancelled(error)) {
        rethrow;
      }

      return UserApi.instance.loginWithKakaoAccount();
    }
  }

  bool _isUserCancelled(Object error) {
    final description = error.toString().toLowerCase();
    return description.contains('cancel') || description.contains('canceled');
  }

  String _messageFor(Object error) {
    if (_isUserCancelled(error)) {
      return '카카오 로그인을 취소했습니다.';
    }

    if (error is KakaoException) {
      return '카카오 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.';
    }

    return '카카오 로그인 중 문제가 발생했습니다.';
  }
}
