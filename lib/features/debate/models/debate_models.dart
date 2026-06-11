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
  String? get verdict =>
      _cleanString(payload['verdict']) ??
      _cleanString(payload['final_verdict']);
  String? get engineStatus => _cleanString(payload['status']);
  String? get errorCode => _cleanString(payload['code']);
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
  return DateTime.tryParse(text);
}
