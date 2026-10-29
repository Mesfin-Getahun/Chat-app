enum CallType {
  audio,
  video,
}

enum CallStatus {
  completed,
  missed,
  declined,
}

class CallRecord {
  final String id;
  final bool isOutgoing;
  final CallType type;
  final DateTime timestamp;
  final int durationSeconds;
  final CallStatus status;

  const CallRecord({
    required this.id,
    required this.isOutgoing,
    required this.type,
    required this.timestamp,
    required this.durationSeconds,
    this.status = CallStatus.completed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isOutgoing': isOutgoing,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'durationSeconds': durationSeconds,
      'status': status.name,
    };
  }

  factory CallRecord.fromJson(Map<String, dynamic> json) {
    return CallRecord(
      id: json['id'] as String,
      isOutgoing: json['isOutgoing'] as bool? ?? true,
      type: CallType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CallType.audio,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.completed,
      ),
    );
  }
}
