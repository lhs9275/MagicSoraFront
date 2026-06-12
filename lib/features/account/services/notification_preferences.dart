import 'package:shared_preferences/shared_preferences.dart';

/// 알림 설정 토글 상태를 로컬에 저장한다.
///
/// 실제 푸시 발송은 아직 없고, 이 값은 사용자 선호를 기록해두기 위한 UI 상태다.
/// 추후 백엔드/Service Worker로 푸시를 붙일 때 이 키들을 그대로 읽어 쓸 수 있다.
class NotificationPreferences {
  NotificationPreferences._();

  static final instance = NotificationPreferences._();

  static const _debateCompletedKey = 'notification.debate_completed';
  static const _followUpAnsweredKey = 'notification.follow_up_answered';

  Future<NotificationPreferenceValues> load() async {
    final preferences = await SharedPreferences.getInstance();
    return NotificationPreferenceValues(
      debateCompleted: preferences.getBool(_debateCompletedKey) ?? false,
      followUpAnswered: preferences.getBool(_followUpAnsweredKey) ?? false,
    );
  }

  Future<void> setDebateCompleted(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_debateCompletedKey, value);
  }

  Future<void> setFollowUpAnswered(bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_followUpAnsweredKey, value);
  }
}

class NotificationPreferenceValues {
  const NotificationPreferenceValues({
    required this.debateCompleted,
    required this.followUpAnswered,
  });

  final bool debateCompleted;
  final bool followUpAnswered;

  NotificationPreferenceValues copyWith({
    bool? debateCompleted,
    bool? followUpAnswered,
  }) {
    return NotificationPreferenceValues(
      debateCompleted: debateCompleted ?? this.debateCompleted,
      followUpAnswered: followUpAnswered ?? this.followUpAnswered,
    );
  }
}
