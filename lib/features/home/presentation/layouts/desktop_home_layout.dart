import 'package:flutter/material.dart';
import 'package:magicsorafront/features/home/presentation/widgets/home_widgets.dart';

class DesktopHomeLayout extends StatelessWidget {
  const DesktopHomeLayout({
    required this.questions,
    required this.questionController,
    required this.onSubmitQuestion,
    required this.onOpenAccount,
    super.key,
  });

  static const designSize = Size(1180, 760);

  final List<String> questions;
  final TextEditingController questionController;
  final VoidCallback onSubmitQuestion;
  final VoidCallback onOpenAccount;

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
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AccountShortcut(onTap: onOpenAccount),
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
