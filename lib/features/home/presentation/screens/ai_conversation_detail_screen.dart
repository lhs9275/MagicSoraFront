import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

class AiConversationMessage {
  const AiConversationMessage({
    required this.agentName,
    required this.message,
    required this.color,
  });

  final String agentName;
  final String message;
  final Color color;
}

const List<AiConversationMessage> _dummyAiConversation = [
  AiConversationMessage(
    agentName: 'Pro Agent',
    message: '이 주제에 대해 찬성 입장의 초기 주장을 생성했습니다.',
    color: AppTheme.primaryTeal,
  ),
  AiConversationMessage(
    agentName: 'Con Agent',
    message: 'Pro Agent와 다른 관점에서 반대 또는 대안 주장을 생성했습니다.',
    color: AppTheme.coral,
  ),
  AiConversationMessage(
    agentName: 'Neutral Evaluator',
    message: '각 주장을 논리성, 근거성, 현실성, 객관성 기준으로 평가했습니다.',
    color: AppTheme.accentGold,
  ),
  AiConversationMessage(
    agentName: 'Validator',
    message: '응답 형식과 내용의 자기모순 여부를 검증했습니다.',
    color: AppTheme.shellPurple,
  ),
  AiConversationMessage(
    agentName: 'Final Synthesizer',
    message: '주장, 평가, 검증 결과를 종합하여 최종 답변을 생성했습니다.',
    color: AppTheme.primaryDark,
  ),
];

class AiConversationDetailScreen extends StatelessWidget {
  const AiConversationDetailScreen({
    super.key,
    this.messages = _dummyAiConversation,
  });

  final List<AiConversationMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 대화 상세')),
      body: OceanShellBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OceanPanel(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white.withValues(alpha: 0.76),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI들이 답변을 만든 과정',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: AppTheme.primaryDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아직 API 연결 전이라 임시 로그를 보여주고 있어요.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final message in messages) ...[
                    _AiMessageCard(message: message),
                    if (message != messages.last) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AiMessageCard extends StatelessWidget {
  const _AiMessageCard({required this.message});

  final AiConversationMessage message;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(16),
      color: Colors.white.withValues(alpha: 0.82),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: message.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(color: message.color, width: 2),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: message.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.agentName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
