import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

/// 앱 부팅 / 로그인 직후 / 홈 hydrate 동안 표시하는 skeleton.
/// 실제 홈 레이아웃(모바일/데스크탑)을 그대로 본뜬 placeholder.
class AppBootSplash extends StatelessWidget {
  const AppBootSplash({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return _MobileHomeSkeleton(message: message);
            }
            return _DesktopHomeSkeleton(message: message);
          },
        ),
      ),
    );
  }
}

const _shimmerPeriod = Duration(milliseconds: 1400);

Widget _wrap(Widget child) {
  return Shimmer.fromColors(
    baseColor: AppTheme.skyBlue.withValues(alpha: 0.22),
    highlightColor: Colors.white.withValues(alpha: 0.85),
    period: _shimmerPeriod,
    child: child,
  );
}

class _MobileHomeSkeleton extends StatelessWidget {
  const _MobileHomeSkeleton({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isShort = constraints.maxHeight < 620;
        final conchHeight = (isShort ? 220.0 : 270.0) * 1.25;
        final conchMaxWidth = constraints.maxWidth < 360 ? 320.0 : 380.0;

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 116),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _wrap(
                      Row(
                        children: const [
                          _PillSkeleton(width: 110),
                          Spacer(),
                          _PillSkeleton(width: 110),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _wrap(
                                _BlockSkeleton(
                                  width: 260,
                                  height: isShort ? 30 : 34,
                                  radius: 10,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: conchMaxWidth,
                                ),
                                child: SizedBox(
                                  height: conchHeight,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: _wrap(
                                        _ConchSkeleton(
                                          height: conchHeight * 0.78,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _wrap(
                                Column(
                                  children: const [
                                    _BlockSkeleton(width: 260, height: 18),
                                    SizedBox(height: 8),
                                    _BlockSkeleton(width: 220, height: 18),
                                  ],
                                ),
                              ),
                              if (message != null) ...[
                                const SizedBox(height: 18),
                                Text(
                                  message!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: AppTheme.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _wrap(const _QuestionInputSkeleton()),
            ),
          ],
        );
      },
    );
  }
}

class _DesktopHomeSkeleton extends StatelessWidget {
  const _DesktopHomeSkeleton({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1180,
                height: 760,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 280,
                            child: Column(
                              children: [
                                Expanded(
                                  child: _wrap(
                                    const _SidebarHistorySkeleton(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _wrap(const _AccountShortcutSkeleton()),
                              ],
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 104),
                              child: _wrap(
                                _ConchPanelSkeleton(message: message),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 328,
                      right: 20,
                      bottom: 20,
                      child: _wrap(const _QuestionInputSkeleton()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillSkeleton extends StatelessWidget {
  const _PillSkeleton({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BlockSkeleton extends StatelessWidget {
  const _BlockSkeleton({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _ConchSkeleton extends StatelessWidget {
  const _ConchSkeleton({required this.height});

  // 실제 InteractiveConch에서 사용하는 이미지 비율 (1546 / 1017)과 기울기.
  static const double _aspectRatio = 1546 / 1017;
  static const double _tilt = 0.22;

  final double height;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _tilt,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        child: Image.asset(
          'assets/images/brand/magic_conch.png',
          height: height,
          width: height * _aspectRatio,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _QuestionInputSkeleton extends StatelessWidget {
  const _QuestionInputSkeleton();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(10),
      color: Colors.white.withValues(alpha: 0.86),
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.5),
      radius: 30,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.skyBlue.withValues(alpha: 0.28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppTheme.skyBlue,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarHistorySkeleton extends StatelessWidget {
  const _SidebarHistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BlockSkeleton(width: 140, height: 18),
          const SizedBox(height: 14),
          for (var i = 0; i < 6; i++) ...[
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.skyBlue.withValues(alpha: 0.14),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: const [
                  _BlockSkeleton(width: 30, height: 30, radius: 12),
                  SizedBox(width: 10),
                  Expanded(
                    child: _BlockSkeleton(
                      width: double.infinity,
                      height: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (i != 5) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AccountShortcutSkeleton extends StatelessWidget {
  const _AccountShortcutSkeleton();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _BlockSkeleton(width: 120, height: 16),
                SizedBox(height: 6),
                _BlockSkeleton(width: 80, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConchPanelSkeleton extends StatelessWidget {
  const _ConchPanelSkeleton({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _BlockSkeleton(width: 320, height: 34, radius: 12),
          const SizedBox(height: 24),
          const _ConchSkeleton(height: 280),
          const SizedBox(height: 24),
          const _BlockSkeleton(width: 320, height: 20),
          const SizedBox(height: 8),
          const _BlockSkeleton(width: 260, height: 20),
          if (message != null) ...[
            const SizedBox(height: 18),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
