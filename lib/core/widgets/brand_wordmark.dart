import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 44});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final eyebrowSize = (fontSize * 0.42).clamp(13.0, 28.0);
    final sparkleSize = (fontSize * 0.48).clamp(15.0, 32.0);
    final gap = (fontSize * 0.18).clamp(6.0, 13.0);
    final underlineHeight = (fontSize * 0.07).clamp(3.0, 5.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: sparkleSize,
              color: AppTheme.accentGold,
            ),
            SizedBox(width: gap),
            Text(
              'MAGIC',
              style: TextStyle(
                fontSize: eyebrowSize,
                fontWeight: FontWeight.w800,
                letterSpacing: eyebrowSize * 0.42,
                color: AppTheme.primaryDark,
                height: 1.0,
              ),
            ),
            SizedBox(width: gap),
            Icon(
              Icons.auto_awesome_rounded,
              size: sparkleSize,
              color: AppTheme.accentGold,
            ),
          ],
        ),
        SizedBox(height: gap * 0.9),
        IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryTeal,
                    AppTheme.shellPurple,
                  ],
                ).createShader(rect),
                child: Text(
                  'Sora',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -fontSize * 0.04,
                    height: 1.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: AppTheme.shadowTint.withValues(alpha: 0.18),
                        blurRadius: fontSize * 0.42,
                        offset: Offset(0, fontSize * 0.2),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: gap * 0.9),
              Container(
                height: underlineHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(underlineHeight),
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryLight,
                      AppTheme.shellPink,
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
