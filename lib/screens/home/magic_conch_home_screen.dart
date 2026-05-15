import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';
import 'debate_home_screen.dart';
import 'magic_conch_result_screen.dart';

class MagicConchHomeScreen extends StatefulWidget {
  const MagicConchHomeScreen({super.key});

  @override
  State<MagicConchHomeScreen> createState() => _MagicConchHomeScreenState();
}

class _MagicConchHomeScreenState extends State<MagicConchHomeScreen> {
  final _questionController = TextEditingController();

  // TODO: 실제 질문 기록 데이터가 생기면 서버/로컬 저장소에서 불러오도록 교체한다.
  final List<String> _questionHistory = const [
    '오늘 토론 주제는 무엇이 좋을까?',
    'AI 의견을 어떻게 비교하면 좋을까?',
    '반박 근거를 더 탄탄하게 만들려면?',
    '최종 결론을 한 문장으로 정리해줘.',
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _openResult() {
    final question = _questionController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MagicConchResultScreen(question: question),
      ),
    );
  }

  void _openDashboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DebateHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 280,
                              child: _QuestionHistoryPanel(
                                questions: _questionHistory,
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              child: _ConchQuestionPanel(
                                controller: _questionController,
                                onPull: _openResult,
                                onOpenDashboard: _openDashboard,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _QuestionHistoryPanel(questions: _questionHistory),
                            const SizedBox(height: 20),
                            _ConchQuestionPanel(
                              controller: _questionController,
                              onPull: _openResult,
                              onOpenDashboard: _openDashboard,
                            ),
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

class _QuestionHistoryPanel extends StatelessWidget {
  const _QuestionHistoryPanel({required this.questions});

  final List<String> questions;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('내가 여태까지 질문했던 목록들', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          for (final question in questions) ...[
            _HistoryTile(question: question),
            if (question != questions.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cream.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        question,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _ConchQuestionPanel extends StatelessWidget {
  const _ConchQuestionPanel({
    required this.controller,
    required this.onPull,
    required this.onOpenDashboard,
  });

  final TextEditingController controller;
  final VoidCallback onPull;
  final VoidCallback onOpenDashboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;
            final title = Text(
              '마법의 소라고동!',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppTheme.primaryDark,
                    fontSize: isCompact ? 30 : 34,
                  ),
              textAlign: isCompact ? TextAlign.left : TextAlign.center,
            );
            final guide = Text(
              '사용법 : 질문을 작성하고 줄을 당겨주세요!',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: isCompact ? TextAlign.left : TextAlign.right,
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title,
                  const SizedBox(height: 10),
                  guide,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Center(child: title)),
                const SizedBox(width: 16),
                Flexible(child: guide),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 620;

            if (isCompact) {
              return Column(
                children: [
                  _InteractiveConch(height: 300, onPull: onPull),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  flex: 5,
                  child: _InteractiveConch(height: 390, onPull: onPull),
                ),
                const SizedBox(width: 18),
                Flexible(
                  flex: 4,
                  child: Text(
                    '소라고동에 달린 고리를 오른쪽으로 잡아당기면 다음 창으로 넘어갑니다.',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        OceanPanel(
          padding: const EdgeInsets.all(18),
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: '사용자가 질문을 입력할 공간',
              prefixIcon: Icon(Icons.edit_note_rounded),
            ),
          ),
        ),
        const SizedBox(height: 14),
        OceanPillButton(
          label: '라운드 대시보드로 이동',
          icon: Icons.dashboard_rounded,
          backgroundColor: AppTheme.accentGold,
          onPressed: onOpenDashboard,
        ),
      ],
    );
  }
}

class _InteractiveConch extends StatefulWidget {
  const _InteractiveConch({required this.height, required this.onPull});

  final double height;
  final VoidCallback onPull;

  @override
  State<_InteractiveConch> createState() => _InteractiveConchState();
}

class _InteractiveConchState extends State<_InteractiveConch> {
  static const _imageAspectRatio = 956 / 694;
  static const _pullThreshold = 54.0;
  static const _maxPullDistance = 92.0;

  double _pullDistance = 0;

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _pullDistance = (_pullDistance + details.delta.dx).clamp(
        0.0,
        _maxPullDistance,
      ).toDouble();
    });
  }

  void _handleDragEnd() {
    final shouldOpenResult = _pullDistance >= _pullThreshold;

    setState(() {
      _pullDistance = 0;
    });

    if (shouldOpenResult) {
      widget.onPull();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.height * _imageAspectRatio + _maxPullDistance;
        final fittedHeight = (maxWidth - _maxPullDistance) / _imageAspectRatio;
        final height = fittedHeight < widget.height ? fittedHeight : widget.height;
        final width = height * _imageAspectRatio;
        final ringSize = height < 340 ? 54.0 : 66.0;

        return Semantics(
          button: true,
          label: '소라고동 줄을 오른쪽으로 당겨 질문하기',
          child: SizedBox(
            width: width + _maxPullDistance,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: width,
                  height: height,
                  child: Image.asset(
                    'assets/images/magic_conch.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  left: width * 0.82,
                  top: height * 0.49,
                  width: width * 0.2 + _maxPullDistance,
                  height: height * 0.18,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: Offset(_pullDistance, 0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.grab,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onHorizontalDragUpdate: _handleDragUpdate,
                          onHorizontalDragEnd: (_) => _handleDragEnd(),
                          onHorizontalDragCancel: _handleDragEnd,
                          child: Container(
                            width: ringSize,
                            height: ringSize,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryDark,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryDark.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.radio_button_checked_rounded,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
