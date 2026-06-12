import 'package:flutter/material.dart';
import 'package:magicsorafront/core/preferences/text_scale_controller.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

const _textScaleText = Color(0xFF30476D);
const _textScaleTextMuted = Color(0xFF6C7C9B);
const _textScaleLineStrong = Color(0xFFC7D4E9);
const _textScaleTeal = Color(0xFF75D6E6);
const _textScaleTealStrong = Color(0xFF4A69AA);
const _textScaleIconBgTop = Color(0xFFF9FBFF);
const _textScaleIconBgBottom = Color(0xFFEBF1FF);

/// 계정 설정 > 글자 크기 설정 화면.
class TextScaleSettingsScreen extends StatelessWidget {
  const TextScaleSettingsScreen({super.key, this.controller});

  final TextScaleController? controller;

  @override
  Widget build(BuildContext context) {
    final scaleController = controller ?? TextScaleController.instance;

    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 22.0;
            final verticalPadding = constraints.maxHeight < 700 ? 18.0 : 26.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TextScaleTopBar(),
                      const SizedBox(height: 18),
                      const _TextScaleIntro(),
                      const SizedBox(height: 14),
                      AnimatedBuilder(
                        animation: scaleController,
                        builder: (context, _) {
                          return _TextScaleOptionsPanel(
                            current: scaleController.value,
                            onSelected: scaleController.update,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      const _TextScalePreviewCard(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TextScaleTopBar extends StatelessWidget {
  const _TextScaleTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TextScaleBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '글자 크기',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _textScaleText,
              fontSize: 28,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextScaleBackButton extends StatelessWidget {
  const _TextScaleBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '뒤로가기',
      child: Material(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          highlightColor: _textScaleTeal.withValues(alpha: 0.08),
          splashColor: _textScaleTeal.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _textScaleLineStrong),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_textScaleIconBgTop, _textScaleIconBgBottom],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x144C8ED4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _textScaleTealStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _TextScaleIntro extends StatelessWidget {
  const _TextScaleIntro();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '읽기 편한 크기로 맞춰보세요',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 크기는 앱 전체에 즉시 반영돼요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextScaleOptionsPanel extends StatelessWidget {
  const _TextScaleOptionsPanel({
    required this.current,
    required this.onSelected,
  });

  final TextScaleLevel current;
  final ValueChanged<TextScaleLevel> onSelected;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          for (final level in TextScaleLevel.values) ...[
            _TextScaleOptionTile(
              level: level,
              isSelected: level == current,
              onTap: () => onSelected(level),
            ),
            if (level != TextScaleLevel.values.last) const _TextScaleDivider(),
          ],
        ],
      ),
    );
  }
}

class _TextScaleOptionTile extends StatelessWidget {
  const _TextScaleOptionTile({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final TextScaleLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      highlightColor: _textScaleTeal.withValues(alpha: 0.08),
      splashColor: _textScaleTeal.withValues(alpha: 0.1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_textScaleIconBgTop, _textScaleIconBgBottom],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _textScaleLineStrong),
              ),
              child: Text(
                '가',
                style: TextStyle(
                  color: _textScaleTealStrong,
                  fontWeight: FontWeight.w900,
                  fontSize: 14 * level.factor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _textScaleText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _captionFor(level),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _textScaleTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? _textScaleTealStrong
                  : _textScaleLineStrong,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _captionFor(TextScaleLevel level) {
    switch (level) {
      case TextScaleLevel.small:
        return '한 화면에 더 많이 보고 싶을 때';
      case TextScaleLevel.normal:
        return '기본 크기';
      case TextScaleLevel.large:
        return '발표하거나 함께 볼 때 좋아요';
    }
  }
}

class _TextScaleDivider extends StatelessWidget {
  const _TextScaleDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 1,
        color: _textScaleLineStrong.withValues(alpha: 0.5),
      ),
    );
  }
}

class _TextScalePreviewCard extends StatelessWidget {
  const _TextScalePreviewCard();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '미리보기',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '마법의 소라고동에게 던지고 싶은 질문을 적어볼까요? 좋은 질문은 좋은 답을 부른답니다.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
