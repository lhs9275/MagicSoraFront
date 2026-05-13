import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/ocean_shell_widgets.dart';

/// 최종 점수만 간단하게 보여주는 화면이다.
class FinalScoreScreen extends StatelessWidget {
  const FinalScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('최종 점수')),
      body: OceanShellBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: OceanPanel(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 34,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withValues(alpha: 0.34),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppTheme.primaryDark,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text('최종 점수', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    Text(
                      '92점',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryDark,
                        fontSize: 56,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '토론 결과가 매우 우수합니다.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
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
