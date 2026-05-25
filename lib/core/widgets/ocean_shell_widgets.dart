import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';

class OceanShellBackground extends StatelessWidget {
  const OceanShellBackground({
    required this.child,
    super.key,
    this.useSafeArea = true,
  });

  final Widget child;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = useSafeArea ? SafeArea(child: child) : child;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.9, -1),
          end: Alignment(0.88, 1),
          colors: [
            Color(0xFFF7FCFA),
            Color(0xFFB8ECEB),
            Color(0xFFE0F5E7),
            Color(0xFFFFF2D6),
          ],
          stops: [0, 0.34, 0.72, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _ModernOceanBackdrop()),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}

class OceanPanel extends StatelessWidget {
  const OceanPanel({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.68),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.1),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.42),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OceanPillButton extends StatelessWidget {
  const OceanPillButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.backgroundColor = AppTheme.shellPink,
    this.foregroundColor = AppTheme.textPrimary,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.64,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                backgroundColor.withValues(alpha: 0.96),
                backgroundColor,
              ],
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.34),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: 58,
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: foregroundColor,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: foregroundColor),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: foregroundColor,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ShellTextField extends StatelessWidget {
  const ShellTextField({
    required this.controller,
    required this.labelText,
    super.key,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.hintText,
    this.icon,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String labelText;
  final Iterable<String>? autofillHints;
  final bool autocorrect;
  final bool enableSuggestions;
  final String? hintText;
  final IconData? icon;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
    );
  }
}

class _ModernOceanBackdrop extends StatelessWidget {
  const _ModernOceanBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _OceanWashPainter()),
    );
  }
}

class _OceanWashPainter extends CustomPainter {
  const _OceanWashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    _paintTopLight(canvas, size);
    _paintWaveBand(
      canvas,
      size,
      y: size.height * 0.18,
      bandHeight: size.height * 0.16,
      amplitude: size.height * 0.035,
      colors: [
        Colors.white.withValues(alpha: 0.22),
        const Color(0xFF7BD9D5).withValues(alpha: 0.16),
      ],
    );
    _paintWaveBand(
      canvas,
      size,
      y: size.height * 0.53,
      bandHeight: size.height * 0.2,
      amplitude: size.height * 0.045,
      colors: [
        Colors.white.withValues(alpha: 0.18),
        const Color(0xFFFFDFAE).withValues(alpha: 0.22),
      ],
    );
    _paintSurfaceLines(canvas, size);
    _paintBottomHaze(canvas, size);
  }

  void _paintTopLight(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x66FFFFFF), Color(0x1A86D9D7), Color(0x00FFFFFF)],
        stops: [0, 0.42, 1],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintWaveBand(
    Canvas canvas,
    Size size, {
    required double y,
    required double bandHeight,
    required double amplitude,
    required List<Color> colors,
  }) {
    final width = size.width;
    final path = Path()
      ..moveTo(0, y)
      ..cubicTo(
        width * 0.18,
        y - amplitude,
        width * 0.35,
        y + amplitude,
        width * 0.55,
        y,
      )
      ..cubicTo(
        width * 0.72,
        y - amplitude,
        width * 0.86,
        y + amplitude * 0.8,
        width,
        y - amplitude * 0.18,
      )
      ..lineTo(width, y + bandHeight)
      ..cubicTo(
        width * 0.78,
        y + bandHeight + amplitude,
        width * 0.62,
        y + bandHeight - amplitude * 0.75,
        width * 0.42,
        y + bandHeight,
      )
      ..cubicTo(
        width * 0.24,
        y + bandHeight + amplitude,
        width * 0.1,
        y + bandHeight - amplitude * 0.35,
        0,
        y + bandHeight + amplitude * 0.65,
      )
      ..close();

    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ).createShader(
            Rect.fromLTWH(0, y - amplitude, width, bandHeight + amplitude * 2),
          );

    canvas.drawPath(path, paint);
  }

  void _paintSurfaceLines(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 7; index += 1) {
      final y = height * (0.1 + index * 0.105);
      final shift = index.isEven ? height * 0.018 : -height * 0.014;
      final path = Path()
        ..moveTo(-width * 0.06, y)
        ..cubicTo(
          width * 0.14,
          y + shift,
          width * 0.28,
          y - shift,
          width * 0.44,
          y + shift * 0.35,
        )
        ..cubicTo(
          width * 0.62,
          y + shift,
          width * 0.78,
          y - shift,
          width * 1.06,
          y + shift * 0.2,
        );

      canvas.drawPath(path, paint);
    }
  }

  void _paintBottomHaze(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      0,
      size.height * 0.58,
      size.width,
      size.height * 0.42,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0),
          const Color(0xFFFFF0D4).withValues(alpha: 0.48),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
