import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

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
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA5F1E3),
            Color(0xFF78DCE9),
            Color(0xFFBDEEF7),
            Color(0xFFFFF3BD),
          ],
          stops: [0, 0.38, 0.72, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(left: 24, top: 42, child: _Bubble(size: 58)),
          const Positioned(right: 34, top: 72, child: _Bubble(size: 34)),
          const Positioned(left: 58, bottom: 84, child: _Bubble(size: 26)),
          const Positioned(right: 84, bottom: 112, child: _Bubble(size: 46)),
          const Positioned(left: 28, bottom: 28, child: _SeaWeed()),
          const Positioned(right: 22, bottom: 24, child: _Coral()),
          const Positioned(left: 96, top: 132, child: _StarCharm(size: 24)),
          const Positioned(right: 96, top: 168, child: _StarCharm(size: 18)),
          const Positioned(
            right: 42,
            bottom: 178,
            child: _ShellCharm(size: 52),
          ),
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
        color: color ?? Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.86),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 12),
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

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

class _StarCharm extends StatelessWidget {
  const _StarCharm({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Icon(
        Icons.star_rounded,
        size: size,
        color: AppTheme.accentGold.withValues(alpha: 0.9),
        shadows: [
          Shadow(
            color: AppTheme.accentDark.withValues(alpha: 0.28),
            offset: const Offset(1.5, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _ShellCharm extends StatelessWidget {
  const _ShellCharm({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(size: Size.square(size), painter: _ShellPainter()),
    );
  }
}

class _ShellPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final body = Paint()
      ..color = AppTheme.shellPink.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.86)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.66)
      ..quadraticBezierTo(
        size.width * 0.18,
        0,
        size.width * 0.5,
        size.height * 0.12,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        0,
        size.width * 0.84,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.88,
      )
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.9,
        size.width * 0.16,
        size.height * 0.66,
      )
      ..close();

    canvas.drawPath(path, body);
    canvas.drawPath(path, stroke);
    for (final x in [0.32, 0.5, 0.68]) {
      canvas.drawLine(
        Offset(size.width * 0.5, size.height * 0.18),
        Offset(size.width * x, size.height * 0.76),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SeaWeed extends StatelessWidget {
  const _SeaWeed();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _WeedBlade(height: 82, color: AppTheme.primaryDark),
          _WeedBlade(height: 58, color: AppTheme.primaryTeal),
          _WeedBlade(height: 72, color: AppTheme.success),
        ],
      ),
    );
  }
}

class _WeedBlade extends StatelessWidget {
  const _WeedBlade({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: height,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.48),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
      ),
    );
  }
}

class _Coral extends StatelessWidget {
  const _Coral();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: 96,
        height: 86,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _CoralBranch(width: 26, height: 70, color: AppTheme.shellPink),
            Positioned(
              left: 16,
              bottom: 0,
              child: _CoralBranch(
                width: 22,
                height: 46,
                color: AppTheme.coralLight,
              ),
            ),
            Positioned(
              right: 14,
              bottom: 0,
              child: _CoralBranch(
                width: 24,
                height: 62,
                color: AppTheme.shellPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoralBranch extends StatelessWidget {
  const _CoralBranch({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.68),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(999)),
      ),
    );
  }
}
