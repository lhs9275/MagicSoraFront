import 'dart:convert';

enum DebateStatus {
  running('RUNNING'),
  done('DONE'),
  degraded('DEGRADED'),
  failed('FAILED'),
  cancelled('CANCELLED');

  const DebateStatus(this.apiValue);

  final String apiValue;

  static DebateStatus fromJson(Object? value) {
    final normalized = value?.toString().trim().toUpperCase() ?? '';
    return DebateStatus.values.firstWhere(
      (status) => status.apiValue == normalized,
      orElse: () => DebateStatus.failed,
    );
  }
}

class DebateListPage {
  const DebateListPage({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  factory DebateListPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .map((item) => DebateSummary.fromJson(_asStringKeyedMap(item)))
              .toList()
        : <DebateSummary>[];

    return DebateListPage(
      items: items,
      nextCursor: _asInt(json['nextCursor']),
      hasNext: json['hasNext'] == true,
    );
  }

  final List<DebateSummary> items;
  final int? nextCursor;
  final bool hasNext;
}

class DebateSummary {
  const DebateSummary({
    required this.id,
    required this.topic,
    required this.status,
    this.category,
    this.finalVerdict,
    this.leadingArgumentId,
    this.totalScore,
    this.errorCode,
    this.createdAt,
    this.finishedAt,
  });

  factory DebateSummary.fromJson(Map<String, dynamic> json) {
    return DebateSummary(
      id: _asInt(json['id']) ?? 0,
      topic: _cleanString(json['topic']) ?? '',
      status: DebateStatus.fromJson(json['status']),
      category: _cleanString(json['category']),
      finalVerdict: _cleanString(json['finalVerdict']),
      leadingArgumentId: _cleanString(json['leadingArgumentId']),
      totalScore: _asDouble(json['totalScore']),
      errorCode: _cleanString(json['errorCode']),
      createdAt: _asDateTime(json['createdAt']),
      finishedAt: _asDateTime(json['finishedAt']),
    );
  }

  final int id;
  final String topic;
  final DebateStatus status;
  final String? category;
  final String? finalVerdict;
  final String? leadingArgumentId;
  final double? totalScore;
  final String? errorCode;
  final DateTime? createdAt;
  final DateTime? finishedAt;
}

class DebateDetail {
  const DebateDetail({
    required this.id,
    required this.userId,
    required this.topic,
    required this.status,
    this.category,
    this.finalVerdict,
    this.leadingArgumentId,
    this.totalScore,
    this.resultJson,
    this.errorCode,
    this.createdAt,
    this.updatedAt,
    this.finishedAt,
  });

  factory DebateDetail.fromJson(Map<String, dynamic> json) {
    return DebateDetail(
      id: _asInt(json['id']) ?? 0,
      userId: _asInt(json['userId']) ?? 0,
      topic: _cleanString(json['topic']) ?? '',
      status: DebateStatus.fromJson(json['status']),
      category: _cleanString(json['category']),
      finalVerdict: _cleanString(json['finalVerdict']),
      leadingArgumentId: _cleanString(json['leadingArgumentId']),
      totalScore: _asDouble(json['totalScore']),
      resultJson: _cleanString(json['resultJson']),
      errorCode: _cleanString(json['errorCode']),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
      finishedAt: _asDateTime(json['finishedAt']),
    );
  }

  final int id;
  final int userId;
  final String topic;
  final DebateStatus status;
  final String? category;
  final String? finalVerdict;
  final String? leadingArgumentId;
  final double? totalScore;
  final String? resultJson;
  final String? errorCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? finishedAt;
}

class DebateCancelResult {
  const DebateCancelResult({required this.id, required this.status});

  factory DebateCancelResult.fromJson(Map<String, dynamic> json) {
    return DebateCancelResult(
      id: _asInt(json['id']) ?? 0,
      status: DebateStatus.fromJson(json['status']),
    );
  }

  final int id;
  final DebateStatus status;
}

class DebateSseEvent {
  DebateSseEvent({required this.event, required this.data})
    : payload = _decodePayload(data);

  final String event;
  final String data;
  final Map<String, dynamic> payload;

  bool get isFinal => event == 'final';
  bool get isError => event == 'error';
  bool get isDelta => event == 'delta';
  bool get isAnswerCompleted => event == 'answer_completed';
  String? get verdict =>
      _cleanString(payload['verdict']) ??
      _cleanString(payload['final_verdict']);
  String? get engineStatus => _cleanString(payload['status']);
  String? get errorCode => _cleanString(payload['code']);
  String? get deltaText {
    final raw = payload['text']?.toString();
    return raw == null || raw.isEmpty ? null : raw;
  }

  int? get questionId => _asInt(payload['questionId']);
  String? get answerText => _cleanString(payload['answer']);

  /// 가이드 2.2: final 이벤트는 leading_argument_id / total_score / arguments / payload를 포함.
  String? get leadingArgumentId =>
      _cleanString(payload['leading_argument_id']) ??
      _cleanString(payload['leadingArgumentId']);

  double? get totalScore =>
      _asDouble(payload['total_score']) ?? _asDouble(payload['totalScore']);

  List<Map<String, dynamic>> get debateArguments {
    final raw = payload['arguments'];
    if (raw is! List) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map)
          item.map((key, value) => MapEntry(key.toString(), value)),
    ];
  }

  Map<String, dynamic> get finalPayload =>
      _asStringKeyedMap(payload['payload']);
}

class DebateQuestionAnswer {
  const DebateQuestionAnswer({
    required this.id,
    required this.question,
    required this.answer,
    this.createdAt,
  });

  factory DebateQuestionAnswer.fromJson(Map<String, dynamic> json) {
    return DebateQuestionAnswer(
      id: _asInt(json['id']) ?? 0,
      question: _cleanString(json['question']) ?? '',
      answer: _cleanString(json['answer']) ?? '',
      createdAt: _asDateTime(json['createdAt']),
    );
  }

  final int id;
  final String question;
  final String answer;
  final DateTime? createdAt;
}

Map<String, dynamic> _decodePayload(String data) {
  final trimmed = data.trim();
  if (trimmed.isEmpty) {
    return const {};
  }

  try {
    final decoded = jsonDecode(trimmed);
    return _asStringKeyedMap(decoded);
  } on FormatException {
    return {'raw': data};
  }
}

Map<String, dynamic> _asStringKeyedMap(Object? value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map(
      (key, nestedValue) => MapEntry(key.toString(), nestedValue),
    );
  }

  return const {};
}

String? _cleanString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _asDateTime(Object? value) {
  final text = _cleanString(value);
  if (text == null) {
    return null;
  }

  // 가이드: 모든 시각은 서버(UTC) 기준 ISO-8601.
  // 'Z' 또는 ±HH:MM 오프셋이 없으면 naive 문자열로 간주해 UTC로 해석한다.
  final hasTimezone =
      text.endsWith('Z') ||
      text.endsWith('z') ||
      RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(text);
  final normalized = hasTimezone ? text : '${text}Z';
  return DateTime.tryParse(normalized);
}
