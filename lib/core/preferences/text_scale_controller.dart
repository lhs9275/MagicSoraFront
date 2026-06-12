import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용자가 선택한 글자 크기 단계.
enum TextScaleLevel { small, normal, large }

extension TextScaleLevelX on TextScaleLevel {
  /// MediaQuery 의 textScaler 에 곱해질 배율.
  double get factor {
    switch (this) {
      case TextScaleLevel.small:
        return 0.88;
      case TextScaleLevel.normal:
        return 1.0;
      case TextScaleLevel.large:
        return 1.16;
    }
  }

  String get label {
    switch (this) {
      case TextScaleLevel.small:
        return '작게';
      case TextScaleLevel.normal:
        return '보통';
      case TextScaleLevel.large:
        return '크게';
    }
  }

  String get storageValue {
    switch (this) {
      case TextScaleLevel.small:
        return 'small';
      case TextScaleLevel.normal:
        return 'normal';
      case TextScaleLevel.large:
        return 'large';
    }
  }

  static TextScaleLevel fromStorageValue(String? raw) {
    switch (raw) {
      case 'small':
        return TextScaleLevel.small;
      case 'large':
        return TextScaleLevel.large;
      case 'normal':
      default:
        return TextScaleLevel.normal;
    }
  }
}

/// 앱 전역에서 글자 크기를 공유하기 위한 컨트롤러. 변경 시 리스너가
/// 즉시 새 값을 반영하도록 [ValueNotifier] 형태로 노출한다.
///
/// 저장은 SharedPreferences 에 슬러그(`small`/`normal`/`large`)로 한다.
class TextScaleController extends ValueNotifier<TextScaleLevel> {
  TextScaleController._() : super(TextScaleLevel.normal) {
    _hydrate();
  }

  static final TextScaleController instance = TextScaleController._();

  static const _storageKey = 'preferences.text_scale';

  Future<void> _hydrate() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    value = TextScaleLevelX.fromStorageValue(raw);
  }

  Future<void> update(TextScaleLevel next) async {
    if (value == next) {
      return;
    }
    value = next;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, next.storageValue);
  }
}
