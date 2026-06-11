import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';

class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.fontSize = 44});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Magic Sora',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AppTheme.textPrimary,
        fontFamily: 'SF Pro Display',
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: -fontSize * 0.035,
        height: 1.02,
        shadows: [
          Shadow(
            color: AppTheme.shadowTint.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
    );
  }
}
