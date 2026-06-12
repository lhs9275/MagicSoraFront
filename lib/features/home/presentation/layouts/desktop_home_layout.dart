import 'package:flutter/material.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/home/models/question_history_entry.dart';
import 'package:magicsorafront/features/home/presentation/widgets/home_widgets.dart';

class DesktopHomeLayout extends StatelessWidget {
  const DesktopHomeLayout({
    required this.questions,
    required this.user,
    required this.questionController,
    required this.questionFocusNode,
    required this.onSubmitQuestion,
    required this.onOpenAccount,
    required this.onOpenQuestionHistory,
    required this.onOpenQuestionFromHistory,
    super.key,
  });

  static const designSize = Size(1180, 760);

  final List<QuestionHistoryEntry> questions;
  final AppUser user;
  final TextEditingController questionController;
  final FocusNode questionFocusNode;
  final VoidCallback onSubmitQuestion;
  final VoidCallback onOpenAccount;
  final VoidCallback onOpenQuestionHistory;
  final ValueChanged<QuestionHistoryEntry> onOpenQuestionFromHistory;

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
                width: designSize.width,
                height: designSize.height,
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
                                  child: QuestionHistoryPanel(
                                    questions: questions,
                                    onViewAll: onOpenQuestionHistory,
                                    onQuestionTap: onOpenQuestionFromHistory,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AccountShortcut(
                                  user: user,
                                  onTap: onOpenAccount,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 104),
                              child: ConchQuestionPanel(
                                onSubmit: onSubmitQuestion,
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
                      child: QuestionInputPanel(
                        controller: questionController,
                        focusNode: questionFocusNode,
                        onSubmit: onSubmitQuestion,
                      ),
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
