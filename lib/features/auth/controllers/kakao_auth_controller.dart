import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/login_result.dart';
import 'package:magicsorafront/features/auth/services/auth_session_store.dart';
import 'package:magicsorafront/features/auth/services/bff_auth_service.dart';

class KakaoAuthController {
  KakaoAuthController({
    AuthSessionStore? authSessionStore,
    BffAuthService? bffAuthService,
  }) : _authSessionStore = authSessionStore ?? AuthSessionStore.instance,
       _bffAuthService = bffAuthService ?? BffAuthService();

  final AuthSessionStore _authSessionStore;
  final BffAuthService _bffAuthService;

  Future<LoginResult> submitKakaoLogin() async {
    try {
      final token = await _login();
      if (token.accessToken.isEmpty) {
        return const LoginResult(
          isSuccess: false,
          message: '카카오 로그인 토큰을 받지 못했습니다.',
        );
      }

      await _logKakaoAccessTokenInfoForDebug();

      final user = await _fetchKakaoUserOrFallback();
      final session = await _bffAuthService.exchangeKakaoAccessToken(
        kakaoAccessToken: token.accessToken,
        fallbackUser: user,
      );
      await _authSessionStore.saveSession(session);

      return LoginResult(
        isSuccess: true,
        message: '${session.user.nickname}님, 로그인에 성공했습니다.',
        user: session.user,
        session: session,
      );
    } catch (error, stackTrace) {
      debugPrint('[Kakao] login failed: ${error.runtimeType} -> $error');
      debugPrint('$stackTrace');
      return LoginResult(isSuccess: false, message: _messageFor(error));
    }
  }

  Future<void> _logKakaoAccessTokenInfoForDebug() async {
    if (!kDebugMode) {
      return;
    }

    try {
      final tokenInfo = await UserApi.instance.accessTokenInfo();
      debugPrint(
        '[Kakao] access token info: '
        'app_id=${tokenInfo.appId}, '
        'user_id=${tokenInfo.id}, '
        'expires_in=${tokenInfo.expiresIn}',
      );
    } catch (error) {
      debugPrint('[Kakao] failed to fetch access token info: $error');
    }
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
    if (kIsWeb) {
      return UserApi.instance.loginWithKakaoAccount();
    }

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

    if (error is BffAuthException) {
      return error.message;
    }

    if (error is KakaoException) {
      final detail = error.message?.trim() ?? '';
      if (detail.isNotEmpty) {
        return '카카오 로그인에 실패했습니다. $detail';
      }
      return '카카오 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.';
    }

    return '카카오 로그인 중 문제가 발생했습니다.';
  }
}
