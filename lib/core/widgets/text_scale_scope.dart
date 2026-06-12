import 'package:flutter/material.dart';
import 'package:magicsorafront/core/preferences/text_scale_controller.dart';

/// 자식 트리의 MediaQuery 에 [TextScaleController] 가 보관 중인 배율을 입혀준다.
///
/// 컨트롤러 값이 바뀌면 [AnimatedBuilder] 를 통해 자식이 다시 빌드된다.
class TextScaleScope extends StatelessWidget {
  const TextScaleScope({required this.child, super.key, this.controller});

  final Widget child;
  final TextScaleController? controller;

  @override
  Widget build(BuildContext context) {
    final scaleController = controller ?? TextScaleController.instance;

    return AnimatedBuilder(
      animation: scaleController,
      builder: (context, _) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(scaleController.value.factor),
          ),
          child: child,
        );
      },
    );
  }
}
