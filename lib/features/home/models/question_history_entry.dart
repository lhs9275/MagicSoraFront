import 'package:magicsorafront/features/debate/models/debate_models.dart';

class QuestionHistoryEntry {
  const QuestionHistoryEntry({
    required this.question,
    required this.answer,
    this.debateId,
    this.status,
    this.createdAt,
  });

  final String question;
  final String answer;
  final int? debateId;
  final DebateStatus? status;
  final DateTime? createdAt;
}
