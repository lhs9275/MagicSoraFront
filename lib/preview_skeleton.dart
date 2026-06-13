import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_boot_splash.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

// Skeleton 디자인/애니메이션만 확인하기 위한 미리보기 진입점.
// 실행: flutter run -t lib/preview_skeleton.dart
void main() {
  runApp(const _SkeletonPreviewApp());
}

class _SkeletonPreviewApp extends StatelessWidget {
  const _SkeletonPreviewApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skeleton Preview',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const _SkeletonPreviewMenu(),
    );
  }
}

class _SkeletonPreviewMenu extends StatelessWidget {
  const _SkeletonPreviewMenu();

  @override
  Widget build(BuildContext context) {
    final entries = <_PreviewEntry>[
      _PreviewEntry(
        title: '앱 부팅 스플래시',
        subtitle: 'main() Kakao SDK 초기화 + 로그인 후 홈 hydrate 동안 표시',
        builder: (_) =>
            const AppBootSplash(message: '소라고동을 깨우는 중이에요…'),
      ),
      _PreviewEntry(
        title: '질문 기록 화면',
        subtitle: '첫 진입 시 API에서 토론 목록을 불러올 때',
        builder: (_) => const _PreviewSection(
          title: '질문 기록 skeleton',
          child: _PreviewHistorySkeletonList(),
        ),
      ),
      _PreviewEntry(
        title: '알림 설정 화면',
        subtitle: '저장된 알림 설정을 불러올 때',
        builder: (_) => _PreviewSection(
          title: '알림 설정 skeleton',
          child: OceanPanel(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Shimmer.fromColors(
              baseColor: const Color(0xFFC7D4E9).withValues(alpha: 0.45),
              highlightColor: Colors.white.withValues(alpha: 0.85),
              period: const Duration(milliseconds: 1400),
              child: Column(
                children: const [
                  _PreviewNotificationSkeletonTile(),
                  _PreviewNotificationDivider(),
                  _PreviewNotificationSkeletonTile(),
                ],
              ),
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      body: OceanShellBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skeleton 미리보기',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '확인할 로딩 화면을 골라주세요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    for (final entry in entries) ...[
                      _PreviewMenuItem(entry: entry),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewEntry {
  const _PreviewEntry({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}

class _PreviewMenuItem extends StatelessWidget {
  const _PreviewMenuItem({required this.entry});

  final _PreviewEntry entry;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: entry.builder),
          );
        },
        child: OceanPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        BackButton(
                          color: AppTheme.primaryDark,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge?.copyWith(fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PreviewHistorySkeletonList extends StatelessWidget {
  const _PreviewHistorySkeletonList();

  static const int _itemCount = 6;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.skyBlue.withValues(alpha: 0.18),
      highlightColor: Colors.white.withValues(alpha: 0.78),
      period: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < _itemCount; index++) ...[
            const _PreviewHistorySkeletonTile(),
            if (index != _itemCount - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _PreviewHistorySkeletonTile extends StatelessWidget {
  const _PreviewHistorySkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.skyBlue.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: const [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewSkeletonBar(width: double.infinity, height: 14),
                SizedBox(height: 8),
                _PreviewSkeletonBar(width: 180, height: 12),
              ],
            ),
          ),
          SizedBox(width: 12),
          _PreviewSkeletonBar(width: 28, height: 28, radius: 14),
          SizedBox(width: 8),
          _PreviewSkeletonBar(width: 28, height: 28, radius: 14),
        ],
      ),
    );
  }
}

class _PreviewNotificationSkeletonTile extends StatelessWidget {
  const _PreviewNotificationSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 140,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewNotificationDivider extends StatelessWidget {
  const _PreviewNotificationDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 1,
        color: const Color(0xFFC7D4E9).withValues(alpha: 0.5),
      ),
    );
  }
}

class _PreviewSkeletonBar extends StatelessWidget {
  const _PreviewSkeletonBar({
    required this.width,
    required this.height,
    this.radius = 6,
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
