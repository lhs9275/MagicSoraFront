import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:magicsorafront/features/home/presentation/screens/evaluation_result_screen.dart';

enum QuestionRequestMode {
  newQuestion('new_question'),
  followUp('follow_up'),
  reEvaluate('re_evaluate');

  const QuestionRequestMode(this.apiValue);

  final String apiValue;
}

class MagicConchResultScreen extends StatefulWidget {
  const MagicConchResultScreen({
    required this.question,
    super.key,
    this.debateId,
    this.initialAnswer,
    this.showAnswerImmediately = false,
    this.showFollowUpInputInitially = false,
    this.debateApiService,
  });

  final String question;
  final int? debateId;
  final String? initialAnswer;
  final bool showAnswerImmediately;
  final bool showFollowUpInputInitially;
  final DebateApiService? debateApiService;

  @override
  State<MagicConchResultScreen> createState() => _MagicConchResultScreenState();
}

class _MagicConchResultScreenState extends State<MagicConchResultScreen> {
  final _followUpController = TextEditingController();
  final List<DebateSseEvent> _streamEvents = [];

  late final DebateApiService _debateApiService;
  late bool _isAnswerReady;
  late bool _showFollowUpInput;

  StreamSubscription<DebateSseEvent>? _streamSubscription;
  String? _streamAnswer;
  String? _streamErrorMessage;
  bool _isStreaming = false;
  bool _didReachTerminalEvent = false;

  String get _trimmedQuestion => widget.question.trim();
  bool get _hasQuestion => _trimmedQuestion.isNotEmpty;
  bool get _isLiveDebate => widget.debateId != null && !_hasInitialAnswer;
  bool get _hasInitialAnswer =>
      widget.initialAnswer != null && widget.initialAnswer!.trim().isNotEmpty;
  bool get _isHistoryAnswerVisible =>
      _isAnswerReady && _hasInitialAnswer && !widget.showFollowUpInputInitially;
  String get _resolvedAnswer => _hasInitialAnswer
      ? widget.initialAnswer!.trim()
      : _streamAnswer ?? _streamErrorMessage ?? _buildTemporaryAnswer();

  @override
  void initState() {
    super.initState();
    _debateApiService = widget.debateApiService ?? DebateApiService();
    _isAnswerReady = widget.showAnswerImmediately && _hasInitialAnswer;
    _showFollowUpInput = widget.showFollowUpInputInitially && _isAnswerReady;
    if (_isLiveDebate) {
      _startDebateStream();
    }
  }

  String _buildTemporaryAnswer() {
    if (_isLiveDebate) {
      return '토론 결과를 기다리고 있어요.';
    }
    return '마법의 소라고동은 이렇게 대답했어요.';
  }

  Map<String, String> _buildFollowUpContext(String followUpQuestion) {
    // TODO: API 요청 body로 전달하면 백엔드가 mode 값으로 처리 흐름을 구분할 수 있다.
    return {
      'mode': QuestionRequestMode.followUp.apiValue,
      'originalQuestion': _trimmedQuestion,
      'currentAnswer': _resolvedAnswer,
      'followUpQuestion': followUpQuestion,
    };
  }

  @override
  void dispose() {
    _followUpController.dispose();
    if (_didReachTerminalEvent || !_isLiveDebate) {
      _streamSubscription?.cancel();
    }
    super.dispose();
  }

  void _startDebateStream() {
    final debateId = widget.debateId;
    if (debateId == null || _isStreaming) {
      return;
    }

    _isStreaming = true;
    debugPrint('[DebateStream] connecting debateId=$debateId');
    _streamSubscription = _debateApiService
        .streamDebate(debateId)
        .listen(
          _handleDebateEvent,
          onError: _handleDebateStreamError,
          onDone: _handleDebateStreamDone,
        );
  }

  void _handleDebateEvent(DebateSseEvent event) {
    _streamEvents.add(event);

    if (event.isFinal) {
      _didReachTerminalEvent = true;
      _streamAnswer = event.verdict ?? '최종 토론 결과가 도착했습니다.';
      _isAnswerReady = true;
      _isStreaming = false;
    } else if (event.isError) {
      _didReachTerminalEvent = true;
      _streamErrorMessage = event.errorCode == null
          ? '토론 중 오류가 발생했습니다.'
          : '토론 중 오류가 발생했습니다. ${event.errorCode}';
      _isAnswerReady = true;
      _isStreaming = false;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleDebateStreamError(Object error) {
    _didReachTerminalEvent = true;
    debugPrint('[DebateStream] error type=${error.runtimeType} message=$error');
    _streamErrorMessage = error is DebateApiException
        ? _formatDebateApiError(error)
        : '토론 스트림 연결에 실패했습니다.';
    _isAnswerReady = true;
    _isStreaming = false;

    if (mounted) {
      setState(() {});
    }
  }

  String _formatDebateApiError(DebateApiException error) {
    final statusCode = error.statusCode;
    if (statusCode == null || error.message.contains('status=')) {
      return error.message;
    }
    return '${error.message} status=$statusCode';
  }

  void _handleDebateStreamDone() {
    _isStreaming = false;
    if (!_isAnswerReady && _streamErrorMessage == null) {
      _streamErrorMessage = '토론 스트림이 종료되었습니다.';
      _isAnswerReady = true;
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _handleLoadingCompleted() {
    if (!mounted || _isAnswerReady) {
      return;
    }

    setState(() {
      _isAnswerReady = true;
    });
  }

  void _openEvaluationResult() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EvaluationResultScreen(
          question: _trimmedQuestion,
          answer: _resolvedAnswer,
        ),
      ),
    );
  }

  void _showAdditionalQuestionInput() {
    setState(() {
      _showFollowUpInput = true;
    });
  }

  Future<void> _cancelDebate() async {
    final debateId = widget.debateId;
    if (debateId == null) {
      return;
    }

    try {
      await _debateApiService.cancelDebate(debateId);
      await _streamSubscription?.cancel();
      _didReachTerminalEvent = true;
      _streamErrorMessage = '취소된 토론입니다.';
      _isAnswerReady = true;
      _isStreaming = false;
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '토론을 취소하지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _submitFollowUpQuestion() {
    final followUpQuestion = _followUpController.text.trim();

    if (followUpQuestion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추가 질문을 입력해주세요.')));
      return;
    }

    final contextPayload = _buildFollowUpContext(followUpQuestion);
    final mode =
        contextPayload['mode'] ?? QuestionRequestMode.followUp.apiValue;
    final followUpPreview = contextPayload['followUpQuestion'] ?? '';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('추가 질문 기능은 API 연결 전입니다. mode=$mode: $followUpPreview'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayQuestion = _hasQuestion ? _trimmedQuestion : '질문이 아직 비어 있어요.';
    final answer = _resolvedAnswer;
    final appBarTitle = widget.showFollowUpInputInitially
        ? '질문 이어가기'
        : _isHistoryAnswerVisible
        ? '이전 답변'
        : '소라고동의 답변';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: OceanShellBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: OceanPanel(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/brand/magic_conch.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Text('질문', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      displayQuestion,
                      style: _hasQuestion
                          ? Theme.of(context).textTheme.bodyLarge
                          : Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryDark,
                              fontSize: 28,
                            ),
                      textAlign: TextAlign.center,
                    ),
                    if (_hasQuestion) ...[
                      if (_isHistoryAnswerVisible) ...[
                        const SizedBox(height: 8),
                        Text(
                          '이전에 받은 답변',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppTheme.primaryDark,
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 22),
                      if (!_isAnswerReady) ...[
                        Text(
                          _isLiveDebate
                              ? 'AI 토론을 진행하고 있어요'
                              : '마법의 소라고동이 곧 답을 들려줄 꺼에요',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.primaryDark,
                                fontSize: 24,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        if (_isLiveDebate)
                          const _LiveLoadingBar()
                        else
                          _TemporaryLoadingBar(
                            onCompleted: _handleLoadingCompleted,
                          ),
                        if (_streamEvents.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _DebateProgressList(events: _streamEvents),
                        ],
                      ] else if (!_hasInitialAnswer) ...[
                        const _CompletedLoadingBar(),
                      ],
                      if (_isAnswerReady) ...[
                        const SizedBox(height: 22),
                        _TemporaryAnswerCard(
                          answer: answer,
                          onTap: _streamErrorMessage == null
                              ? _openEvaluationResult
                              : null,
                        ),
                      ],
                      if (_isLiveDebate && !_isAnswerReady) ...[
                        const SizedBox(height: 18),
                        OceanPillButton(
                          label: '토론 취소',
                          icon: Icons.stop_circle_rounded,
                          backgroundColor: AppTheme.coral,
                          onPressed: _cancelDebate,
                        ),
                      ],
                    ],
                    if (_hasQuestion && _isAnswerReady) ...[
                      const SizedBox(height: 28),
                      OceanPillButton(
                        label: '추가로 질문하기',
                        icon: Icons.add_comment_rounded,
                        backgroundColor: AppTheme.primaryLight,
                        onPressed: _showAdditionalQuestionInput,
                      ),
                      if (_showFollowUpInput) ...[
                        const SizedBox(height: 14),
                        _FollowUpQuestionBox(
                          controller: _followUpController,
                          onSubmit: _submitFollowUpQuestion,
                        ),
                      ],
                      const SizedBox(height: 14),
                    ] else ...[
                      const SizedBox(height: 32),
                    ],
                    OceanPillButton(
                      label: '새 질문하기',
                      icon: Icons.keyboard_return_rounded,
                      backgroundColor: AppTheme.deepNavy,
                      foregroundColor: Colors.white,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
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

class _TemporaryAnswerCard extends StatelessWidget {
  const _TemporaryAnswerCard({required this.answer, required this.onTap});

  final String answer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final canOpenEvaluation = onTap != null;

    return Semantics(
      button: canOpenEvaluation,
      label: canOpenEvaluation ? '답변을 눌러 평가 결과 보기' : '답변',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: OceanPanel(
            padding: const EdgeInsets.all(18),
            color: Colors.white.withValues(alpha: 0.78),
            child: Column(
              children: [
                Text(
                  answer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  canOpenEvaluation ? '답변을 눌러 평가 결과 보기' : '다시 질문해 주세요',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebateProgressList extends StatelessWidget {
  const _DebateProgressList({required this.events});

  final List<DebateSseEvent> events;

  @override
  Widget build(BuildContext context) {
    final visibleEvents = events.length > 3
        ? events.sublist(events.length - 3)
        : events;

    return Column(
      children: [
        for (final event in visibleEvents) ...[
          _DebateProgressRow(event: event),
          if (event != visibleEvents.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _DebateProgressRow extends StatelessWidget {
  const _DebateProgressRow({required this.event});

  final DebateSseEvent event;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.white.withValues(alpha: 0.68),
      child: Row(
        children: [
          Icon(
            _iconForEvent(event.event),
            size: 18,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _labelForEvent(event),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForEvent(String eventName) {
    return switch (eventName) {
      'stage_completed' => Icons.check_circle_rounded,
      'gate' => Icons.verified_rounded,
      'final' => Icons.flag_circle_rounded,
      'error' => Icons.error_rounded,
      _ => Icons.auto_awesome_rounded,
    };
  }

  String _labelForEvent(DebateSseEvent event) {
    final stage =
        event.payload['stage']?.toString().trim() ??
        event.payload['role']?.toString().trim() ??
        '';

    return switch (event.event) {
      'stage_started' => stage.isEmpty ? '토론 단계를 시작했습니다' : '$stage 단계를 시작했습니다',
      'stage_completed' => stage.isEmpty ? '토론 단계를 마쳤습니다' : '$stage 단계를 마쳤습니다',
      'gate' => '검증 단계를 통과하고 있습니다',
      'final' => '최종 결과가 도착했습니다',
      'error' =>
        event.errorCode == null ? '토론 오류가 발생했습니다' : '토론 오류: ${event.errorCode}',
      _ => stage.isEmpty ? '토론 이벤트를 수신했습니다' : stage,
    };
  }
}

class _FollowUpQuestionBox extends StatelessWidget {
  const _FollowUpQuestionBox({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(12),
      color: Colors.white.withValues(alpha: 0.68),
      child: Column(
        children: [
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              hintText: '추가 질문을 입력해주세요',
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: AppTheme.cream.withValues(alpha: 0.92),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: AppTheme.border),
              ),
            ),
          ),
          const SizedBox(height: 12),
          OceanPillButton(
            label: '추가 질문 보내기',
            icon: Icons.send_rounded,
            backgroundColor: AppTheme.primaryLight,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _TemporaryLoadingBar extends StatefulWidget {
  const _TemporaryLoadingBar({required this.onCompleted});

  final VoidCallback onCompleted;

  @override
  State<_TemporaryLoadingBar> createState() => _TemporaryLoadingBarState();
}

class _TemporaryLoadingBarState extends State<_TemporaryLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _didNotifyCompleted = false;

  @override
  void initState() {
    super.initState();
    // API 연결 전 임시 UI라 5초 동안 0%에서 100%까지 채우는 애니메이션을 사용한다.
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed && !_didNotifyCompleted) {
              _didNotifyCompleted = true;
              widget.onCompleted();
            }
          })
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _LoadingBarShell(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _controller.value,
              heightFactor: 1,
              child: child,
            ),
          );
        },
        child: const _LoadingBarFill(),
      ),
    );
  }
}

class _CompletedLoadingBar extends StatelessWidget {
  const _CompletedLoadingBar();

  @override
  Widget build(BuildContext context) {
    return const _LoadingBarShell(child: _LoadingBarFill());
  }
}

class _LiveLoadingBar extends StatelessWidget {
  const _LiveLoadingBar();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          height: 8,
          child: LinearProgressIndicator(
            minHeight: 8,
            color: AppTheme.primaryTeal,
            backgroundColor: Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ),
    );
  }
}

class _LoadingBarShell extends StatelessWidget {
  const _LoadingBarShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 360),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(
          width: double.infinity,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LoadingBarFill extends StatelessWidget {
  const _LoadingBarFill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withValues(alpha: 0.92),
            AppTheme.primaryTeal,
          ],
        ),
      ),
    );
  }
}
