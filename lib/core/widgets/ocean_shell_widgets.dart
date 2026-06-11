import 'dart:math' as math;

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
            Color(0xFFE1FAF3),
            Color(0xFFD7F6EF),
            Color(0xFFC9F1EA),
            Color(0xFFBFEDE6),
            Color(0xFFE4F6E6),
            Color(0xFFFFF2D2),
            Color(0xFFFFF8E7),
          ],
          stops: [0, 0.48, 0.62, 0.72, 0.8, 0.89, 1],
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
    this.borderColor,
    this.radius = AppTheme.panelRadius,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.surfaceCard.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? AppTheme.glassBorder.withValues(alpha: 0.58),
          width: 1.1,
        ),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppTheme.shadowTint.withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
                BoxShadow(
                  color: AppTheme.cream.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ]
            : null,
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
    this.fontSize = 17,
    this.showBorder = true,
    this.showShadow = true,
    this.useGradient = true,
    this.borderRadius = AppTheme.softControlRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isLoading;
  final double fontSize;
  final bool showBorder;
  final bool showShadow;
  final bool useGradient;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final startColor = Color.lerp(backgroundColor, Colors.white, 0.18)!;
    final endColor = Color.lerp(backgroundColor, AppTheme.accentLight, 0.1)!;
    final shadowColor = Color.lerp(backgroundColor, AppTheme.skyBlue, 0.18)!;
    final radius = BorderRadius.circular(borderRadius);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.64,
      child: SizedBox(
        width: double.infinity,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: useGradient ? null : backgroundColor,
            gradient: useGradient
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor],
                  )
                : null,
            borderRadius: radius,
            border: showBorder
                ? Border.all(
                    color: Color.lerp(
                      backgroundColor,
                      Colors.white,
                      0.44,
                    )!.withValues(alpha: 0.72),
                    width: 1.1,
                  )
                : null,
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.42),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              hoverColor: Colors.white.withValues(alpha: 0.12),
              focusColor: Colors.white.withValues(alpha: 0.16),
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: AppTheme.skyBlue.withValues(alpha: 0.12),
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: 54,
                child: Center(
                  child: isLoading
                      ? _ButtonLoadingIndicator(color: foregroundColor)
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
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
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

class _ButtonLoadingIndicator extends StatelessWidget {
  const _ButtonLoadingIndicator({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '처리 중',
      child: SizedBox(
        width: 46,
        height: 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          child: LinearProgressIndicator(
            backgroundColor: color.withValues(alpha: 0.16),
            valueColor: AlwaysStoppedAnimation<Color>(
              color.withValues(alpha: 0.78),
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
      cursorColor: AppTheme.primaryTeal,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.34,
      ),
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

class _ModernOceanBackdrop extends StatefulWidget {
  const _ModernOceanBackdrop();

  @override
  State<_ModernOceanBackdrop> createState() => _ModernOceanBackdropState();
}

class _ModernOceanBackdropState extends State<_ModernOceanBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(painter: _OceanWashPainter(_controller.value));
        },
      ),
    );
  }
}

class _OceanWashPainter extends CustomPainter {
  const _OceanWashPainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final cycle = phase * math.pi * 2;

    _paintOceanBody(canvas, size, cycle);
    _paintTopLight(canvas, size);
    _paintWaveBand(
      canvas,
      size,
      y: size.height * 0.18,
      bandHeight: size.height * 0.16,
      amplitude: size.height * 0.035,
      phaseOffset: cycle,
      colors: [
        Colors.white.withValues(alpha: 0.12),
        AppTheme.primaryLight.withValues(alpha: 0.23),
      ],
    );
    _paintSurfaceLines(canvas, size, cycle);
    _paintShorelineSand(canvas, size, cycle);
    _paintShorelineBlend(canvas, size, cycle);
    _paintShorelineWave(canvas, size, cycle);
  }

  void _paintTopLight(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.42),
          AppTheme.primaryLight.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0),
        ],
        stops: [0, 0.38, 1],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintWaveBand(
    Canvas canvas,
    Size size, {
    required double y,
    required double bandHeight,
    required double amplitude,
    required double phaseOffset,
    required List<Color> colors,
  }) {
    final width = size.width;
    final animatedY = y + math.sin(phaseOffset) * amplitude * 0.24;
    final animatedAmplitude = amplitude * (0.92 + math.cos(phaseOffset) * 0.08);
    final drift = math.sin(phaseOffset * 0.7) * width * 0.035;
    final startX = -width * 0.08 + drift;
    final endX = width * 1.08 + drift;
    final path = Path()
      ..moveTo(startX, animatedY)
      ..cubicTo(
        width * 0.18 + drift,
        animatedY - animatedAmplitude,
        width * 0.35 + drift,
        animatedY + animatedAmplitude,
        width * 0.55 + drift,
        animatedY,
      )
      ..cubicTo(
        width * 0.72 + drift,
        animatedY - animatedAmplitude,
        width * 0.86 + drift,
        animatedY + animatedAmplitude * 0.8,
        endX,
        animatedY - animatedAmplitude * 0.18,
      )
      ..lineTo(endX, animatedY + bandHeight)
      ..cubicTo(
        width * 0.78 + drift,
        animatedY + bandHeight + animatedAmplitude,
        width * 0.62 + drift,
        animatedY + bandHeight - animatedAmplitude * 0.75,
        width * 0.42 + drift,
        animatedY + bandHeight,
      )
      ..cubicTo(
        width * 0.24 + drift,
        animatedY + bandHeight + animatedAmplitude,
        width * 0.1 + drift,
        animatedY + bandHeight - animatedAmplitude * 0.35,
        startX,
        animatedY + bandHeight + animatedAmplitude * 0.65,
      )
      ..close();

    final paint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ).createShader(
            Rect.fromLTWH(
              0,
              animatedY - animatedAmplitude,
              width,
              bandHeight + animatedAmplitude * 2,
            ),
          );

    canvas.drawPath(path, paint);
  }

  void _paintSurfaceLines(Canvas canvas, Size size, double cycle) {
    final width = size.width;
    final height = size.height;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    for (var index = 0; index < 7; index += 1) {
      final y =
          height * (0.1 + index * 0.105) +
          math.sin(cycle + index * 0.77) * height * 0.007;
      final shift = index.isEven ? height * 0.018 : -height * 0.014;
      final drift = math.cos(cycle * 0.8 + index) * width * 0.025;
      final path = Path()
        ..moveTo(-width * 0.08 + drift, y)
        ..cubicTo(
          width * 0.14 + drift,
          y + shift,
          width * 0.28 + drift,
          y - shift,
          width * 0.44 + drift,
          y + shift * 0.35,
        )
        ..cubicTo(
          width * 0.62 + drift,
          y + shift,
          width * 0.78 + drift,
          y - shift,
          width * 1.08 + drift,
          y + shift * 0.2,
        );

      canvas.drawPath(path, paint);
    }
  }

  void _paintOceanBody(Canvas canvas, Size size, double cycle) {
    final oceanPath = _buildOceanBodyFillPath(size, cycle);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.78);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD7F6EF).withValues(alpha: 0.18),
          const Color(0xFFC9F1EA).withValues(alpha: 0.2),
          AppTheme.primaryLight.withValues(alpha: 0.22),
          AppTheme.skyBlue.withValues(alpha: 0.14),
        ],
        stops: const [0, 0.5, 0.78, 1],
      ).createShader(rect);
    canvas.drawPath(oceanPath, paint);
  }

  void _paintShorelineSand(Canvas canvas, Size size, double cycle) {
    final sandPath = _buildBeachFillPath(size, cycle);
    final rect = Rect.fromLTWH(
      0,
      size.height * 0.41,
      size.width,
      size.height * 0.59,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFFF6D6).withValues(alpha: 0.38),
          const Color(0xFFFFF1CB).withValues(alpha: 0.72),
          const Color(0xFFFFE6BE).withValues(alpha: 0.86),
          AppTheme.cream.withValues(alpha: 0.94),
        ],
        stops: const [0, 0.18, 0.58, 1],
      ).createShader(rect);
    canvas.drawPath(sandPath, paint);
  }

  void _paintShorelineBlend(Canvas canvas, Size size, double cycle) {
    final beachAnchors = _buildBeachBoundaryAnchors(size, cycle);
    final upperAnchors = [
      for (final point in beachAnchors)
        Offset(point.dx, point.dy - size.height * 0.012),
    ];
    final lowerAnchors = [
      for (final point in beachAnchors)
        Offset(point.dx, point.dy + size.height * 0.048),
    ];
    final blendPath = _buildBandPath(
      frontAnchors: lowerAnchors,
      backAnchors: upperAnchors,
    );
    final blendRect = Rect.fromLTWH(
      0,
      size.height * 0.4,
      size.width,
      size.height * 0.22,
    );
    final blendPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFBFEDE6).withValues(alpha: 0.22),
          AppTheme.primaryLight.withValues(alpha: 0.18),
          const Color(0xFFEAF7E6).withValues(alpha: 0.16),
          const Color(0xFFFFF2D2).withValues(alpha: 0.18),
        ],
        stops: const [0, 0.28, 0.62, 1],
      ).createShader(blendRect);

    canvas.drawPath(blendPath, blendPaint);
  }

  void _paintShorelineWave(Canvas canvas, Size size, double cycle) {
    final tide = Curves.easeInOut.transform(
      (math.sin(cycle * 0.85 - math.pi * 0.5) + 1) * 0.5,
    );
    final shorelineY =
        size.height * (0.6 + tide * 0.075) - _shorelineLift(size);
    final foamAmplitude = size.height * (0.019 + tide * 0.01);
    final waterSheetFrontY = shorelineY + size.height * (0.018 + tide * 0.006);
    final waterSheetFrontAmplitude = foamAmplitude * 0.88;
    final waveWashBackY = shorelineY + size.height * (0.055 + tide * 0.012);
    final waveWashBackAmplitude = foamAmplitude * 0.72;
    final surgeReachY = shorelineY + size.height * (0.105 + tide * 0.035);
    final surgeReachAmplitude = foamAmplitude * (0.46 + tide * 0.12);

    final beachMask = _buildBeachFillPath(size, cycle);
    final beachAnchors = _buildBeachBoundaryAnchors(size, cycle);
    final waterSheetFrontAnchors = _buildShorelineAnchors(
      size,
      waterSheetFrontY,
      waterSheetFrontAmplitude,
      cycle + 0.08,
    );
    final foamAnchors = _buildShorelineAnchors(
      size,
      shorelineY,
      foamAmplitude,
      cycle,
    );
    final wetSandPath = _buildShorelinePath(
      size,
      shorelineY + size.height * (0.024 - tide * 0.008),
      foamAmplitude * 0.66,
      cycle + 0.9,
    );
    final foamPath = _buildSmoothPath(foamAnchors);
    final incomingWashPath = _buildBandPath(
      frontAnchors: _buildShorelineAnchors(
        size,
        surgeReachY,
        surgeReachAmplitude,
        cycle + 0.6,
      ),
      backAnchors: beachAnchors,
    );
    final waterSheetPath = _buildBandPath(
      frontAnchors: waterSheetFrontAnchors,
      backAnchors: beachAnchors,
    );
    final waveWashBand = _buildShorelineBandPath(
      size: size,
      frontY: shorelineY,
      frontAmplitude: foamAmplitude,
      frontCycle: cycle,
      backY: waveWashBackY,
      backAmplitude: waveWashBackAmplitude,
      backCycle: cycle + 0.32,
    );
    final trailingFoamPath = _buildShorelinePath(
      size,
      shorelineY + size.height * (0.022 + (1 - tide) * 0.01),
      foamAmplitude * 0.58,
      cycle + 0.45,
    );

    canvas.save();
    canvas.clipPath(beachMask);

    final incomingWashPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFBFEDE6).withValues(alpha: 0.28 + tide * 0.08),
              AppTheme.primaryLight.withValues(alpha: 0.28 + tide * 0.08),
              AppTheme.skyBlue.withValues(alpha: 0.14 + tide * 0.04),
              const Color(0xFFEAF7E6).withValues(alpha: 0.06),
            ],
            stops: const [0, 0.32, 0.68, 1],
          ).createShader(
            Rect.fromLTWH(
              0,
              shorelineY - size.height * 0.12,
              size.width,
              size.height * 0.42,
            ),
          );
    canvas.drawPath(incomingWashPath, incomingWashPaint);

    final waterSheetPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFC9F1EA).withValues(alpha: 0.32),
              const Color(0xFFBFEDE6).withValues(alpha: 0.34),
              AppTheme.primaryLight.withValues(alpha: 0.24),
              const Color(0xFFE9F7E8).withValues(alpha: 0.12),
            ],
            stops: const [0, 0.32, 0.72, 1],
          ).createShader(
            Rect.fromLTWH(
              0,
              shorelineY - size.height * 0.08,
              size.width,
              size.height * 0.22,
            ),
          );
    canvas.drawPath(waterSheetPath, waterSheetPaint);

    final waveWashFillPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              const Color(0xFFBFEDE6).withValues(alpha: 0.34),
              AppTheme.primaryLight.withValues(alpha: 0.28),
              AppTheme.skyBlue.withValues(alpha: 0.12),
            ],
            stops: const [0, 0.26, 0.68, 1],
          ).createShader(
            Rect.fromLTWH(
              0,
              shorelineY - size.height * 0.02,
              size.width,
              size.height * 0.2,
            ),
          );
    canvas.drawPath(waveWashBand, waveWashFillPaint);

    final waveCorePaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * (0.04 + tide * 0.01)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(foamPath, waveCorePaint);

    final wetSandPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryTeal.withValues(alpha: 0.24),
              AppTheme.primaryLight.withValues(alpha: 0.08),
              Colors.transparent,
            ],
            stops: const [0, 0.42, 1],
          ).createShader(
            Rect.fromLTWH(0, shorelineY - 8, size.width, size.height * 0.18),
          )
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.028
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(wetSandPath, wetSandPaint);

    final trailingFoamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.008
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(trailingFoamPath, trailingFoamPaint);

    canvas.restore();

    final waveGlowPaint = Paint()
      ..color = AppTheme.primaryLight.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.03
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(foamPath, waveGlowPaint);

    final foamShadowPaint = Paint()
      ..color = AppTheme.primaryTeal.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.014
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(foamPath, foamShadowPaint);

    final foamPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.009
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(foamPath, foamPaint);
  }

  Path _buildShorelineBandPath({
    required Size size,
    required double frontY,
    required double frontAmplitude,
    required double frontCycle,
    required double backY,
    required double backAmplitude,
    required double backCycle,
  }) {
    final frontAnchors = _buildShorelineAnchors(
      size,
      frontY,
      frontAmplitude,
      frontCycle,
    );
    final backAnchors = _buildShorelineAnchors(
      size,
      backY,
      backAmplitude,
      backCycle,
    );
    return _buildBandPath(frontAnchors: frontAnchors, backAnchors: backAnchors);
  }

  Path _buildBeachFillPath(Size size, double cycle) {
    final path = _buildBeachBoundaryPath(size, cycle);
    path
      ..lineTo(size.width * 1.08, size.height)
      ..lineTo(-size.width * 0.08, size.height)
      ..close();
    return path;
  }

  Path _buildOceanBodyFillPath(Size size, double cycle) {
    final path = _buildBeachBoundaryPath(size, cycle);
    path
      ..lineTo(size.width * 1.08, -size.height * 0.04)
      ..lineTo(-size.width * 0.08, -size.height * 0.04)
      ..close();
    return path;
  }

  Path _buildBeachBoundaryPath(Size size, double cycle) {
    return _buildSmoothPath(_buildBeachBoundaryAnchors(size, cycle));
  }

  List<Offset> _buildBeachBoundaryAnchors(Size size, double cycle) {
    final width = size.width;
    final height = size.height;
    final shorelineLift = _shorelineLift(size);
    final drift = math.sin(cycle * 0.35 + 0.8) * width * 0.012;
    final liftA = math.sin(cycle * 0.42 + 0.5) * height * 0.01;
    final liftB = math.cos(cycle * 0.37 + 1.6) * height * 0.012;
    final liftC = math.sin(cycle * 0.29 + 2.3) * height * 0.009;
    final liftD = math.cos(cycle * 0.33 + 3.2) * height * 0.011;
    final liftE = math.sin(cycle * 0.27 + 4.1) * height * 0.008;

    return <Offset>[
      Offset(-width * 0.08, height * 0.47 + liftA - shorelineLift),
      Offset(width * 0.12 + drift, height * 0.44 + liftB - shorelineLift),
      Offset(width * 0.28 - drift * 0.2, height * 0.49 + liftC - shorelineLift),
      Offset(
        width * 0.46 + drift * 0.15,
        height * 0.53 + liftD - shorelineLift,
      ),
      Offset(width * 0.68 + drift * 0.3, height * 0.57 + liftC - shorelineLift),
      Offset(width * 0.86 - drift * 0.1, height * 0.61 + liftE - shorelineLift),
      Offset(width * 1.08, height * 0.64 + liftD * 0.7 - shorelineLift),
    ];
  }

  double _shorelineLift(Size size) => size.height * 0.034;

  Path _buildShorelinePath(
    Size size,
    double y,
    double amplitude,
    double cycle,
  ) {
    return _buildSmoothPath(_buildShorelineAnchors(size, y, amplitude, cycle));
  }

  List<Offset> _buildShorelineAnchors(
    Size size,
    double y,
    double amplitude,
    double cycle,
  ) {
    final width = size.width;
    final horizontalShift = math.sin(cycle * 0.55) * width * 0.018;
    final crestA = math.sin(cycle + 0.2) * amplitude * 0.36;
    final crestB = math.cos(cycle * 0.92 + 0.7) * amplitude * 0.62;
    final crestC = math.sin(cycle * 1.18 + 1.4) * amplitude * 0.48;
    final crestD = math.cos(cycle + 2.2) * amplitude * 0.54;
    final crestE = math.sin(cycle * 0.86 + 2.9) * amplitude * 0.42;
    final crestF = math.cos(cycle * 1.06 + 4.0) * amplitude * 0.34;
    final crestG = math.sin(cycle * 0.74 + 4.7) * amplitude * 0.28;

    return <Offset>[
      Offset(-width * 0.08, y - size.height * 0.03 + crestA),
      Offset(
        width * 0.08 + horizontalShift * 0.25,
        y - size.height * 0.018 - amplitude * 0.92 + crestB,
      ),
      Offset(
        width * 0.24 - horizontalShift * 0.18,
        y + size.height * 0.012 + amplitude * 1.05 + crestC,
      ),
      Offset(
        width * 0.42 + horizontalShift * 0.14,
        y - size.height * 0.004 + amplitude * 0.18 + crestD,
      ),
      Offset(
        width * 0.62 + horizontalShift * 0.26,
        y + size.height * 0.026 + amplitude * 0.94 + crestE,
      ),
      Offset(
        width * 0.82 - horizontalShift * 0.12,
        y + size.height * 0.01 - amplitude * 0.7 + crestF,
      ),
      Offset(width * 1.08, y + size.height * 0.046 + crestG),
    ];
  }

  Path _buildBandPath({
    required List<Offset> frontAnchors,
    required List<Offset> backAnchors,
  }) {
    final reversedBackAnchors = backAnchors.reversed.toList();

    final path = Path()..moveTo(frontAnchors.first.dx, frontAnchors.first.dy);
    _appendSmoothCurve(path, frontAnchors);
    path.lineTo(reversedBackAnchors.first.dx, reversedBackAnchors.first.dy);
    _appendSmoothCurve(path, reversedBackAnchors);
    path.close();
    return path;
  }

  Path _buildSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    _appendSmoothCurve(path, points);
    return path;
  }

  void _appendSmoothCurve(Path path, List<Offset> points) {
    for (var index = 0; index < points.length - 1; index += 1) {
      final p0 = index == 0 ? points[index] : points[index - 1];
      final p1 = points[index];
      final p2 = points[index + 1];
      final p3 = index + 2 < points.length ? points[index + 2] : p2;

      final control1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final control2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );

      path.cubicTo(
        control1.dx,
        control1.dy,
        control2.dx,
        control2.dy,
        p2.dx,
        p2.dy,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OceanWashPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}
