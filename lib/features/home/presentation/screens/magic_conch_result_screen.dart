import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/debate/models/debate_models.dart';
import 'package:magicsorafront/features/debate/services/debate_api_service.dart';
import 'package:magicsorafront/features/home/presentation/screens/evaluation_result_screen.dart';

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
  final _scrollController = ScrollController();
  final List<DebateSseEvent> _streamEvents = [];
  final List<DebateQuestionAnswer> _qaHistory = [];

  late final DebateApiService _debateApiService;
  late bool _isAnswerReady;
  late bool _showFollowUpInput;

  StreamSubscription<DebateSseEvent>? _streamSubscription;
  StreamSubscription<DebateSseEvent>? _qaSubscription;
  String? _streamAnswer;
  String? _streamErrorMessage;
  bool _isStreaming = false;
  bool _isSubmittingFollowUp = false;
  bool _didReachTerminalEvent = false;

  // 가이드 2.2 final 이벤트의 추가 필드 보관.
  double? _finalTotalScore;
  String? _finalLeadingArgumentId;

  // Q&A streaming state
  String _streamingAnswer = '';
  String? _streamingQuestion;
  bool _isQaStreaming = false;
  String? _qaErrorMessage;
  bool _isLoadingQaHistory = false;
  String? _qaHistoryLoadError;

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

  // Q&A는 토론이 DONE/DEGRADED 상태일 때만 가능.
  // - 라이브 토론이면 최종 이벤트가 정상으로 끝났을 때
  // - 이전 답변이 보이는 경우는 항상 허용 (서버가 409로 막아주면 메시지 표시)
  bool get _canAskFollowUp {
    if (widget.debateId == null) {
      return false;
    }
    if (_hasInitialAnswer) {
      return true;
    }
    return _isAnswerReady && _streamErrorMessage == null;
  }

  @override
  void initState() {
    super.initState();
    _debateApiService = widget.debateApiService ?? DebateApiService();
    _isAnswerReady = widget.showAnswerImmediately && _hasInitialAnswer;
    _showFollowUpInput = widget.showFollowUpInputInitially && _isAnswerReady;
    if (_isLiveDebate) {
      _startDebateStream();
    }
    if (widget.debateId != null && _hasInitialAnswer) {
      unawaited(_loadQaHistory());
    }
  }

  String _buildTemporaryAnswer() {
    if (_isLiveDebate) {
      return '토론 결과를 기다리고 있어요.';
    }
    return '마법의 소라고동은 이렇게 대답했어요.';
  }

  @override
  void dispose() {
    _followUpController.dispose();
    _scrollController.dispose();
    if (_didReachTerminalEvent || !_isLiveDebate) {
      _streamSubscription?.cancel();
    }
    _qaSubscription?.cancel();
    super.dispose();
  }

  /// 답변이 새 토큰으로 자라날 때마다 페이지의 마지막 줄이 보이도록 따라가 스크롤한다.
  /// `Duration.zero`를 넘기면 즉시(jump) 이동해 빠른 토큰 흐름에서도 끊김 없이 동기화된다.
  void _followQaScroll({
    Duration duration = const Duration(milliseconds: 180),
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position;
      final target = position.maxScrollExtent;
      if ((position.pixels - target).abs() < 1) {
        return;
      }
      if (duration == Duration.zero) {
        _scrollController.jumpTo(target);
        return;
      }
      _scrollController.animateTo(
        target,
        duration: duration,
        curve: Curves.easeOut,
      );
    });
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
      _finalTotalScore = event.totalScore;
      _finalLeadingArgumentId = event.leadingArgumentId;
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
    _openEvaluationResultFor(_trimmedQuestion, _resolvedAnswer);
  }

  void _openEvaluationResultFor(String question, String answer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            EvaluationResultScreen(question: question, answer: answer),
      ),
    );
  }

  void _showAdditionalQuestionInput() {
    if (_isSubmittingFollowUp || _isQaStreaming) {
      return;
    }

    setState(() {
      _showFollowUpInput = true;
    });
  }

  void _handleFollowUpSubmit() {
    unawaited(_submitFollowUpQuestion());
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

  Future<void> _loadQaHistory() async {
    final debateId = widget.debateId;
    if (debateId == null) {
      return;
    }

    setState(() {
      _isLoadingQaHistory = true;
      _qaHistoryLoadError = null;
    });

    try {
      final history = await _debateApiService.fetchQuestions(debateId);
      if (!mounted) {
        return;
      }
      setState(() {
        _qaHistory
          ..clear()
          ..addAll(history);
        _isLoadingQaHistory = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingQaHistory = false;
        _qaHistoryLoadError = error is DebateApiException
            ? error.message
            : '이전 추가 질문을 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _submitFollowUpQuestion() async {
    final followUpQuestion = _followUpController.text.trim();

    if (_isSubmittingFollowUp || _isQaStreaming) {
      return;
    }

    if (followUpQuestion.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추가 질문을 입력해주세요.')));
      return;
    }

    if (followUpQuestion.length > 500) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('추가 질문은 500자 이하로 입력해주세요.')));
      return;
    }

    final debateId = widget.debateId;
    if (debateId == null || !_canAskFollowUp) {
      // debateId가 없으면 기존처럼 새 토론으로 폴백 (히스토리 진입이 아닌 경우)
      await _startNewDebateFromFollowUp(followUpQuestion);
      return;
    }

    setState(() {
      _isSubmittingFollowUp = true;
      _isQaStreaming = true;
      _streamingAnswer = '';
      _streamingQuestion = followUpQuestion;
      _qaErrorMessage = null;
      _showFollowUpInput = false;
      _followUpController.clear();
    });

    // 추가 질문 카드를 화면 안으로 끌어오고, 이후 delta마다 따라가도록 한다.
    _followQaScroll();

    final completer = Completer<void>();
    _qaSubscription = _debateApiService
        .askQuestion(debateId, followUpQuestion)
        .listen(
          _handleQaEvent,
          onError: (Object error) {
            _handleQaError(error);
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          onDone: () {
            _handleQaDone();
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          cancelOnError: true,
        );

    await completer.future;
  }

  Future<void> _startNewDebateFromFollowUp(String followUpQuestion) async {
    setState(() {
      _isSubmittingFollowUp = true;
    });

    try {
      final debateId = await _debateApiService.startDebate(followUpQuestion);
      if (!mounted) {
        return;
      }

      setState(() {
        _followUpController.clear();
        _showFollowUpInput = false;
        _isSubmittingFollowUp = false;
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => MagicConchResultScreen(
            question: followUpQuestion,
            debateId: debateId,
            debateApiService: _debateApiService,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is DebateApiException
          ? error.message
          : '추가 질문을 시작하지 못했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _isSubmittingFollowUp = false;
      });
    }
  }

  void _handleQaEvent(DebateSseEvent event) {
    if (!mounted) {
      return;
    }

    if (event.isDelta) {
      final text = event.deltaText;
      if (text == null || text.isEmpty) {
        return;
      }
      setState(() {
        _streamingAnswer += text;
      });
      // 토큰이 빠르게 누적될 때마다 즉시(jump) 따라가 답변 끝이 가려지지 않게 한다.
      _followQaScroll(duration: Duration.zero);
    } else if (event.isAnswerCompleted) {
      final answerText = event.answerText ?? _streamingAnswer;
      final questionId = event.questionId ?? 0;
      final question = _streamingQuestion ?? '';
      setState(() {
        _qaHistory.add(
          DebateQuestionAnswer(
            id: questionId,
            question: question,
            answer: answerText,
            createdAt: DateTime.now(),
          ),
        );
        _streamingAnswer = '';
        _streamingQuestion = null;
        _isQaStreaming = false;
        _isSubmittingFollowUp = false;
      });
      // 새로 합류한 이력 카드가 보이도록 부드럽게 맞춘다.
      _followQaScroll();
    } else if (event.isError) {
      setState(() {
        _qaErrorMessage = event.errorCode == null
            ? '답변 생성 중 오류가 발생했어요.'
            : '답변 생성 중 오류: ${event.errorCode}';
        _streamingAnswer = '';
        _streamingQuestion = null;
        _isQaStreaming = false;
        _isSubmittingFollowUp = false;
      });
    }
  }

  void _handleQaError(Object error) {
    if (!mounted) {
      return;
    }

    final message = error is DebateApiException
        ? error.message
        : '추가 질문에 실패했습니다.';
    setState(() {
      _qaErrorMessage = message;
      _streamingAnswer = '';
      _streamingQuestion = null;
      _isQaStreaming = false;
      _isSubmittingFollowUp = false;
    });
  }

  void _handleQaDone() {
    if (!mounted) {
      return;
    }

    if (_isQaStreaming) {
      setState(() {
        _qaErrorMessage ??= '답변이 중간에 끊겼어요. 다시 시도해주세요.';
        _streamingAnswer = '';
        _streamingQuestion = null;
        _isQaStreaming = false;
        _isSubmittingFollowUp = false;
      });
    }
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
            controller: _scrollController,
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
                          totalScore: _finalTotalScore,
                          leadingArgumentId: _finalLeadingArgumentId,
                        ),
                      ],
                      if (_isAnswerReady && widget.debateId != null) ...[
                        if (_isLoadingQaHistory) ...[
                          const SizedBox(height: 14),
                          const _QaHistoryLoadingNote(),
                        ],
                        if (_qaHistoryLoadError != null) ...[
                          const SizedBox(height: 12),
                          _QaInlineNotice(
                            icon: Icons.error_outline_rounded,
                            color: AppTheme.coral,
                            message: _qaHistoryLoadError!,
                            onRetry: _loadQaHistory,
                          ),
                        ],
                        if (_qaHistory.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          _QaHistorySection(entries: _qaHistory),
                        ],
                        if (_isQaStreaming || _streamingAnswer.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          _QaStreamingCard(
                            question:
                                _streamingQuestion ?? '추가 질문 답변을 받고 있어요',
                            partialAnswer: _streamingAnswer,
                          ),
                        ],
                        if (_qaErrorMessage != null) ...[
                          const SizedBox(height: 12),
                          _QaInlineNotice(
                            icon: Icons.warning_amber_rounded,
                            color: AppTheme.coral,
                            message: _qaErrorMessage!,
                          ),
                        ],
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
                    if (_hasQuestion &&
                        _isAnswerReady &&
                        _streamErrorMessage == null) ...[
                      const SizedBox(height: 28),
                      if (_showFollowUpInput)
                        _FollowUpQuestionBox(
                          controller: _followUpController,
                          isSubmitting: _isSubmittingFollowUp,
                          onSubmit: _handleFollowUpSubmit,
                        )
                      else if (!_isQaStreaming)
                        OceanPillButton(
                          label: '추가로 질문하기',
                          icon: Icons.add_comment_rounded,
                          backgroundColor: AppTheme.primaryLight,
                          onPressed: _showAdditionalQuestionInput,
                        ),
                      const SizedBox(height: 14),
                    ] else ...[
                      const SizedBox(height: 32),
                    ],
                    OceanPillButton(
                      label: _hasInitialAnswer ? '질문목록으로 돌아가기' : '새 질문하기',
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
  const _TemporaryAnswerCard({
    required this.answer,
    required this.onTap,
    this.totalScore,
    this.leadingArgumentId,
  });

  final String answer;
  final VoidCallback? onTap;
  final double? totalScore;
  final String? leadingArgumentId;

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
                if (totalScore != null) ...[
                  _FinalScorePill(
                    totalScore: totalScore!,
                    leadingArgumentId: leadingArgumentId,
                  ),
                  const SizedBox(height: 12),
                ],
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

class _FinalScorePill extends StatelessWidget {
  const _FinalScorePill({
    required this.totalScore,
    required this.leadingArgumentId,
  });

  final double totalScore;
  final String? leadingArgumentId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: AppTheme.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            '총점 ${totalScore.toStringAsFixed(1)} / 10',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (leadingArgumentId != null && leadingArgumentId!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              '· ${leadingArgumentId!}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QaHistorySection extends StatelessWidget {
  const _QaHistorySection({required this.entries});

  final List<DebateQuestionAnswer> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '이전에 주고받은 추가 질문',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w900,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < entries.length; index++) ...[
          _QaHistoryCard(entry: entries[index]),
          if (index != entries.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _QaHistoryCard extends StatelessWidget {
  const _QaHistoryCard({required this.entry});

  final DebateQuestionAnswer entry;

  @override
  Widget build(BuildContext context) {
    return _QaCardShell(
      borderColor: AppTheme.skyBlue.withValues(alpha: 0.22),
      questionTitle: '추가 질문',
      questionText: entry.question,
      answerTitle: '답변',
      answerText: entry.answer,
    );
  }
}

class _QaStreamingCard extends StatelessWidget {
  const _QaStreamingCard({
    required this.question,
    required this.partialAnswer,
  });

  final String question;
  final String partialAnswer;

  @override
  Widget build(BuildContext context) {
    final displayText = partialAnswer.isEmpty
        ? '소라고동이 답변을 적고 있어요…'
        : partialAnswer;

    return _QaCardShell(
      borderColor: AppTheme.primaryTeal.withValues(alpha: 0.34),
      questionTitle: '추가 질문',
      questionText: question,
      answerTitle: '답변',
      answerText: displayText,
      answerLeading: const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: AppTheme.primaryTeal,
        ),
      ),
    );
  }
}

/// 추가 질문/답변 카드 공통 셸. 메인 질문/답변 영역과 동일한 타이포그래피를 사용한다.
class _QaCardShell extends StatelessWidget {
  const _QaCardShell({
    required this.borderColor,
    required this.questionTitle,
    required this.questionText,
    required this.answerTitle,
    required this.answerText,
    this.answerLeading,
  });

  final Color borderColor;
  final String questionTitle;
  final String questionText;
  final String answerTitle;
  final String answerText;
  final Widget? answerLeading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sectionTitleStyle = theme.textTheme.titleMedium?.copyWith(
      color: AppTheme.primaryDark,
      fontWeight: FontWeight.w900,
    );
    final questionStyle = theme.textTheme.bodyLarge;
    final answerStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppTheme.textPrimary,
      fontWeight: FontWeight.w800,
    );

    return OceanPanel(
      padding: const EdgeInsets.all(18),
      color: Colors.white.withValues(alpha: 0.82),
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            questionTitle,
            style: sectionTitleStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            questionText,
            style: questionStyle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (answerLeading != null) ...[
                answerLeading!,
                const SizedBox(width: 8),
              ],
              Text(answerTitle, style: sectionTitleStyle),
            ],
          ),
          const SizedBox(height: 6),
          Text(answerText, style: answerStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QaHistoryLoadingNote extends StatelessWidget {
  const _QaHistoryLoadingNote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          '이전 추가 질문을 불러오는 중이에요',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _QaInlineNotice extends StatelessWidget {
  const _QaInlineNotice({
    required this.icon,
    required this.color,
    required this.message,
    this.onRetry,
  });

  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      color: Colors.white.withValues(alpha: 0.82),
      borderColor: color.withValues(alpha: 0.4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: const Text('다시 시도')),
          ],
        ],
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
    final rawStage =
        event.payload['stage']?.toString().trim() ??
        event.payload['role']?.toString().trim() ??
        '';
    final stage = _localizedStageLabel(rawStage);

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

  String _localizedStageLabel(String rawStage) {
    return switch (rawStage.toLowerCase()) {
      'pro' => '찬성 측',
      'con' => '반대 측',
      'neutral_evaluator' => '중립 평가',
      'validator' => '검증',
      _ => rawStage,
    };
  }
}

class _FollowUpQuestionBox extends StatelessWidget {
  const _FollowUpQuestionBox({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;

        return OceanPanel(
          padding: EdgeInsets.all(isCompact ? 8 : 10),
          color: Colors.white.withValues(alpha: 0.78),
          borderColor: AppTheme.skyBlue.withValues(alpha: 0.4),
          radius: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minHeight: 52,
                        maxHeight: 94,
                      ),
                      child: Focus(
                        onKeyEvent: (node, event) {
                          if (event is KeyDownEvent &&
                              event.logicalKey == LogicalKeyboardKey.enter &&
                              !HardwareKeyboard.instance.isShiftPressed) {
                            if (!isSubmitting) onSubmit();
                            return KeyEventResult.handled;
                          }
                          return KeyEventResult.ignored;
                        },
                        child: TextField(
                          controller: controller,
                          enabled: !isSubmitting,
                          minLines: 1,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => onSubmit(),
                          decoration: InputDecoration(
                            hintText: '추가 질문을 입력해주세요',
                          prefixIcon: const Icon(
                            Icons.edit_note_rounded,
                            size: 22,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 42,
                            minHeight: 42,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            2,
                            15,
                            16,
                            15,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.94),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              color: AppTheme.skyBlue.withValues(alpha: 0.28),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide(
                              color: AppTheme.skyBlue.withValues(alpha: 0.28),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryTeal,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: '추가 질문 보내기',
                    child: SizedBox.square(
                      dimension: isCompact ? 48 : 52,
                      child: Material(
                        color: AppTheme.skyBlue,
                        shape: const CircleBorder(),
                        elevation: 0,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isSubmitting ? null : onSubmit,
                          child: Center(
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppTheme.textPrimary,
                                    ),
                                  )
                                : Transform.translate(
                                    offset: const Offset(1.5, 0),
                                    child: const Icon(
                                      Icons.send_rounded,
                                      color: AppTheme.textPrimary,
                                      size: 21,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
