import 'package:flutter/material.dart';

/// PC 폭(≥ [_mobileFrameBreakpoint])에서는 SnackBar 를 모바일 프레임 폭
/// 안에 떠 있는 형태로, 그 미만에서는 기존(화면 폭 가득) 동작으로 표시한다.
///
/// 모든 사용자 알림은 가능한 이 헬퍼를 거치도록 한다. SnackBarBehavior.floating
/// 일 때 width 지정이 동작하므로 PC 에서만 width 를 채워준다.
const double _mobileFrameBreakpoint = 600;
const double _mobileFrameWidth = 460;

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  final isPc = screenWidth >= _mobileFrameBreakpoint;

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
      behavior: isPc ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      width: isPc ? _mobileFrameWidth : null,
      shape: isPc
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
            )
          : null,
    ),
  );
}
