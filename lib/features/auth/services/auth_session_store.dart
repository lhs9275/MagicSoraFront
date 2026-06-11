import 'dart:convert';

import 'package:magicsorafront/features/auth/models/auth_session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬에 현재 인증 세션을 저장해 이후 API 호출에 재사용할 수 있게 한다.
class AuthSessionStore {
  AuthSessionStore._();

  static const _sessionKey = 'auth.session';
  static final instance = AuthSessionStore._();

  AuthSession? _cachedSession;

  AuthSession? get currentSession => _cachedSession;
  String? get accessToken => _cachedSession?.accessToken;

  Future<void> saveSession(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sessionKey, jsonEncode(session.toJson()));
    _cachedSession = session;
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

    final decoded = jsonDecode(rawSession);
    if (decoded is! Map) {
      return null;
    }

    final session = AuthSession.fromJson(
      decoded.map((key, value) => MapEntry(key.toString(), value)),
    );
    _cachedSession = session;
    return session;
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    _cachedSession = null;
  }
}
