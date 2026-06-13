import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/app_snack_bar.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/account/services/notification_preferences.dart';

const _notifText = Color(0xFF30476D);
const _notifTextMuted = Color(0xFF6C7C9B);
const _notifLineStrong = Color(0xFFC7D4E9);
const _notifTeal = Color(0xFF75D6E6);
const _notifTealStrong = Color(0xFF4A69AA);
const _notifIconBgTop = Color(0xFFF9FBFF);
const _notifIconBgBottom = Color(0xFFEBF1FF);

/// 계정 설정 > 알림 설정 화면.
///
/// 현재는 로컬 토글만 저장한다. 실제 푸시 발송은 백엔드/Service Worker가 붙은 뒤에
/// 이 값을 읽어 결정하도록 설계되어 있다.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, this.preferences});

  final NotificationPreferences? preferences;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late final NotificationPreferences _preferences;
  NotificationPreferenceValues? _values;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? NotificationPreferences.instance;
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final loaded = await _preferences.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _values = loaded;
    });
  }

  Future<void> _updateDebateCompleted(bool value) async {
    if (_values == null) {
      return;
    }
    if (value) {
      // 켜는 동작은 안내 메시지만 보여주고 즉시 꺼진 상태로 되돌린다.
      // 토글이 잠깐 ON 으로 보였다가 다시 OFF 로 떨어지면서 안내가 떠야
      // 사용자가 "켤 수 없다"는 점을 시각적으로도 알아챌 수 있다.
      _showInAppOnlyNotice();
      setState(() {
        _values = _values!.copyWith(debateCompleted: true);
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) {
        return;
      }
    }
    setState(() {
      _values = _values!.copyWith(debateCompleted: false);
    });
    await _preferences.setDebateCompleted(false);
  }

  Future<void> _updateFollowUpAnswered(bool value) async {
    if (_values == null) {
      return;
    }
    if (value) {
      _showInAppOnlyNotice();
      setState(() {
        _values = _values!.copyWith(followUpAnswered: true);
      });
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) {
        return;
      }
    }
    setState(() {
      _values = _values!.copyWith(followUpAnswered: false);
    });
    await _preferences.setFollowUpAnswered(false);
  }

  void _showInAppOnlyNotice() {
    if (!mounted) {
      return;
    }
    showAppSnackBar(
      context,
      '앱에서만 알림을 켜고 끌 수 있어요.',
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final values = _values;

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
                      const _NotificationTopBar(),
                      const SizedBox(height: 18),
                      const _NotificationIntro(),
                      const SizedBox(height: 18),
                      if (values == null)
                        const _NotificationLoadingPanel()
                      else
                        _NotificationOptionsPanel(
                          values: values,
                          onDebateCompletedChanged: _updateDebateCompleted,
                          onFollowUpAnsweredChanged: _updateFollowUpAnswered,
                        ),
                      const SizedBox(height: 16),
                      const _NotificationFootnote(),
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

class _NotificationTopBar extends StatelessWidget {
  const _NotificationTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NotificationBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '알림 설정',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _notifText,
              fontSize: 28,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationBackButton extends StatelessWidget {
  const _NotificationBackButton({required this.onPressed});

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
          highlightColor: _notifTeal.withValues(alpha: 0.08),
          splashColor: _notifTeal.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _notifLineStrong),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_notifIconBgTop, _notifIconBgBottom],
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
              color: _notifTealStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationIntro extends StatelessWidget {
  const _NotificationIntro();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '어떤 알림을 받을까요?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래에서 켠 항목만 도착해요. 기본은 켜짐이고, 언제든지 바꿀 수 있어요.',
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

class _NotificationOptionsPanel extends StatelessWidget {
  const _NotificationOptionsPanel({
    required this.values,
    required this.onDebateCompletedChanged,
    required this.onFollowUpAnsweredChanged,
  });

  final NotificationPreferenceValues values;
  final ValueChanged<bool> onDebateCompletedChanged;
  final ValueChanged<bool> onFollowUpAnsweredChanged;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          _NotificationToggleTile(
            icon: Icons.forum_outlined,
            title: '토론 완료 알림',
            subtitle: '토론이 끝나 결과가 도착하면 알려드릴게요.',
            value: values.debateCompleted,
            onChanged: onDebateCompletedChanged,
          ),
          const _NotificationDivider(),
          _NotificationToggleTile(
            icon: Icons.add_comment_outlined,
            title: '추가 질문 답변 알림',
            subtitle: '추가 질문에 대한 답이 다 작성되면 알려드릴게요.',
            value: values.followUpAnswered,
            onChanged: onFollowUpAnsweredChanged,
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      highlightColor: _notifTeal.withValues(alpha: 0.08),
      splashColor: _notifTeal.withValues(alpha: 0.1),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                  colors: [_notifIconBgTop, _notifIconBgBottom],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _notifLineStrong),
              ),
              child: Icon(icon, color: _notifTealStrong, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _notifText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _notifTextMuted,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: _notifTealStrong,
              activeTrackColor: _notifTeal.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationDivider extends StatelessWidget {
  const _NotificationDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(height: 1, color: _notifLineStrong.withValues(alpha: 0.5)),
    );
  }
}

class _NotificationLoadingPanel extends StatelessWidget {
  const _NotificationLoadingPanel();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: _notifLineStrong.withValues(alpha: 0.45),
        highlightColor: Colors.white.withValues(alpha: 0.85),
        period: const Duration(milliseconds: 1400),
        child: Column(
          children: const [
            _NotificationSkeletonTile(),
            _NotificationDivider(),
            _NotificationSkeletonTile(),
          ],
        ),
      ),
    );
  }
}

class _NotificationSkeletonTile extends StatelessWidget {
  const _NotificationSkeletonTile();

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

class _NotificationFootnote extends StatelessWidget {
  const _NotificationFootnote();

  @override
  Widget build(BuildContext context) {
    return Text(
      '알림은 앱 안에서만 켜고 끌 수 있어요.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
