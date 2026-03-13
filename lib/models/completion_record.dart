/// Represents a student's post-class completion record.
class CompletionRecord {
  final String id;
  final String studentId;
  final String classSessionId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String learnedToday;
  final String feedback;

  const CompletionRecord({
    required this.id,
    required this.studentId,
    required this.classSessionId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.learnedToday,
    required this.feedback,
  });

  factory CompletionRecord.fromMap(Map<String, dynamic> map, String id) {
    return CompletionRecord(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      classSessionId: map['classSessionId'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      learnedToday: map['learnedToday'] as String? ?? '',
      feedback: map['feedback'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classSessionId': classSessionId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
  }
}
