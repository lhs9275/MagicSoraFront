import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬에 현재 인증 세션을 저장해 이후 API 호출에 재사용할 수 있게 한다.
class AuthSessionStore {
  AuthSessionStore._();

  static const _sessionKey = 'auth.session';
  static const _nicknameKey = 'profile.nickname';
  static final instance = AuthSessionStore._();

  AuthSession? _cachedSession;

  /// 세션이 새로 저장되거나 비워질 때 알림을 받는 listenable.
  /// 앱 루트에서 이걸 구독해 refresh 실패로 세션이 사라지면 로그인 화면으로 돌려보낸다.
  final ValueNotifier<AuthSession?> sessionListenable =
      ValueNotifier<AuthSession?>(null);

  AuthSession? get currentSession => _cachedSession;
  String? get accessToken => _cachedSession?.accessToken;

  Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(session.toJson()));
    _cachedSession = session;
    sessionListenable.value = session;
  }

  Future<AuthSession?> loadSession() async {
    if (_cachedSession != null) {
      return _cachedSession;
    }

    final preferences = await SharedPreferences.getInstance();
    final rawSession = preferences.getString(_sessionKey);
    if (rawSession == null || rawSession.trim().isEmpty) {
      return null;
    }

    AuthSession session;
    try {
      final decoded = jsonDecode(rawSession);
      if (decoded is! Map) {
        await preferences.remove(_sessionKey);
        return null;
      }
      session = AuthSession.fromJson(
        decoded.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      // 저장된 JSON 이 깨졌다 — 다음 부팅에서 또 시도하지 않도록 비워둔다.
      await preferences.remove(_sessionKey);
      return null;
    }

    // accessToken 이 비어있는 세션은 의미가 없다. 절반만 저장됐거나 손상된 상태이니
    // listenable 을 오염시키지 않고 디스크에서도 지운다.
    if (session.accessToken.trim().isEmpty) {
      await preferences.remove(_sessionKey);
      return null;
    }

    _cachedSession = session;
    sessionListenable.value = session;
    return session;
  }

  Future<AppUser> hydrateUser(AppUser fallbackUser) async {
    final session = await loadSession();
    if (session != null) {
      return session.user;
    }

    final preferences = await SharedPreferences.getInstance();
    final nickname = preferences.getString(_nicknameKey)?.trim() ?? '';
    if (nickname.isEmpty) {
      return fallbackUser;
    }

    return fallbackUser.copyWith(nickname: nickname);
  }

  Future<AppUser> saveNickname({
    required String nickname,
    required AppUser fallbackUser,
  }) async {
    final cleanedNickname = nickname.trim();
    final preferences = await SharedPreferences.getInstance();
    final session = await loadSession();

    if (session != null) {
      final updatedUser = session.user.copyWith(nickname: cleanedNickname);
      await saveSession(session.copyWith(user: updatedUser));
      await preferences.remove(_nicknameKey);
      return updatedUser;
    }

    await preferences.setString(_nicknameKey, cleanedNickname);
    return fallbackUser.copyWith(nickname: cleanedNickname);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    await preferences.remove(_nicknameKey);
    _cachedSession = null;
    sessionListenable.value = null;
  }
}
