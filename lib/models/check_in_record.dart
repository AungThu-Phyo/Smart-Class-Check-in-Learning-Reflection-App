/// Represents a student's pre-class check-in record.
class CheckInRecord {
  final String id;
  final String studentId;
  final String classSessionId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final String previousTopic;
  final String expectedTopic;

  /// Mood score 1–5:
  /// 1=😡 Very negative, 2=🙁 Negative, 3=😐 Neutral,
  /// 4=🙂 Positive, 5=😄 Very positive
  final int moodScore;

  const CheckInRecord({
    required this.id,
    required this.studentId,
    required this.classSessionId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.previousTopic,
    required this.expectedTopic,
    required this.moodScore,
  });

  factory CheckInRecord.fromMap(Map<String, dynamic> map, String id) {
    return CheckInRecord(
      id: id,
      studentId: map['studentId'] as String? ?? '',
      classSessionId: map['classSessionId'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      previousTopic: map['previousTopic'] as String? ?? '',
      expectedTopic: map['expectedTopic'] as String? ?? '',
      moodScore: map['moodScore'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'classSessionId': classSessionId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'moodScore': moodScore,
    };
  }
}
