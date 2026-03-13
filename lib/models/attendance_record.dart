class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.classTitle,
    required this.sessionDate,
    required this.status,
    this.checkInAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracyMeters,
    this.checkInDistanceMeters,
    this.checkInWithinGeofence,
    this.checkInQrValue,
    this.previousTopic,
    this.expectedTopic,
    this.moodBeforeClass,
    this.finishAt,
    this.finishLatitude,
    this.finishLongitude,
    this.finishAccuracyMeters,
    this.finishDistanceMeters,
    this.finishWithinGeofence,
    this.finishQrValue,
    this.learnedToday,
    this.classFeedback,
  });

  final String id;
  final String sessionId;
  final String classTitle;
  final DateTime sessionDate;
  final String status;
  final DateTime? checkInAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInAccuracyMeters;
  final double? checkInDistanceMeters;
  final bool? checkInWithinGeofence;
  final String? checkInQrValue;
  final String? previousTopic;
  final String? expectedTopic;
  final int? moodBeforeClass;
  final DateTime? finishAt;
  final double? finishLatitude;
  final double? finishLongitude;
  final double? finishAccuracyMeters;
  final double? finishDistanceMeters;
  final bool? finishWithinGeofence;
  final String? finishQrValue;
  final String? learnedToday;
  final String? classFeedback;

  bool get isCheckedIn => checkInAt != null;
  bool get isCompleted => finishAt != null;

  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? classTitle,
    DateTime? sessionDate,
    String? status,
    DateTime? checkInAt,
    double? checkInLatitude,
    double? checkInLongitude,
    double? checkInAccuracyMeters,
    double? checkInDistanceMeters,
    bool? checkInWithinGeofence,
    String? checkInQrValue,
    String? previousTopic,
    String? expectedTopic,
    int? moodBeforeClass,
    DateTime? finishAt,
    double? finishLatitude,
    double? finishLongitude,
    double? finishAccuracyMeters,
    double? finishDistanceMeters,
    bool? finishWithinGeofence,
    String? finishQrValue,
    String? learnedToday,
    String? classFeedback,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      classTitle: classTitle ?? this.classTitle,
      sessionDate: sessionDate ?? this.sessionDate,
      status: status ?? this.status,
      checkInAt: checkInAt ?? this.checkInAt,
      checkInLatitude: checkInLatitude ?? this.checkInLatitude,
      checkInLongitude: checkInLongitude ?? this.checkInLongitude,
      checkInAccuracyMeters: checkInAccuracyMeters ?? this.checkInAccuracyMeters,
      checkInDistanceMeters: checkInDistanceMeters ?? this.checkInDistanceMeters,
      checkInWithinGeofence:
          checkInWithinGeofence ?? this.checkInWithinGeofence,
      checkInQrValue: checkInQrValue ?? this.checkInQrValue,
      previousTopic: previousTopic ?? this.previousTopic,
      expectedTopic: expectedTopic ?? this.expectedTopic,
      moodBeforeClass: moodBeforeClass ?? this.moodBeforeClass,
      finishAt: finishAt ?? this.finishAt,
      finishLatitude: finishLatitude ?? this.finishLatitude,
      finishLongitude: finishLongitude ?? this.finishLongitude,
      finishAccuracyMeters: finishAccuracyMeters ?? this.finishAccuracyMeters,
      finishDistanceMeters: finishDistanceMeters ?? this.finishDistanceMeters,
      finishWithinGeofence:
          finishWithinGeofence ?? this.finishWithinGeofence,
      finishQrValue: finishQrValue ?? this.finishQrValue,
      learnedToday: learnedToday ?? this.learnedToday,
      classFeedback: classFeedback ?? this.classFeedback,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'session_id': sessionId,
      'class_title': classTitle,
      'session_date': sessionDate.toIso8601String(),
      'status': status,
      'check_in_at': checkInAt?.toIso8601String(),
      'check_in_latitude': checkInLatitude,
      'check_in_longitude': checkInLongitude,
      'check_in_accuracy_meters': checkInAccuracyMeters,
      'check_in_distance_meters': checkInDistanceMeters,
      'check_in_within_geofence':
          checkInWithinGeofence == null ? null : (checkInWithinGeofence! ? 1 : 0),
      'check_in_qr_value': checkInQrValue,
      'previous_topic': previousTopic,
      'expected_topic': expectedTopic,
      'mood_before_class': moodBeforeClass,
      'finish_at': finishAt?.toIso8601String(),
      'finish_latitude': finishLatitude,
      'finish_longitude': finishLongitude,
      'finish_accuracy_meters': finishAccuracyMeters,
      'finish_distance_meters': finishDistanceMeters,
      'finish_within_geofence':
          finishWithinGeofence == null ? null : (finishWithinGeofence! ? 1 : 0),
      'finish_qr_value': finishQrValue,
      'learned_today': learnedToday,
      'class_feedback': classFeedback,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      classTitle: map['class_title'] as String,
      sessionDate: DateTime.parse(map['session_date'] as String),
      status: map['status'] as String,
      checkInAt: _parseDateTime(map['check_in_at']),
      checkInLatitude: _asDouble(map['check_in_latitude']),
      checkInLongitude: _asDouble(map['check_in_longitude']),
      checkInAccuracyMeters: _asDouble(map['check_in_accuracy_meters']),
      checkInDistanceMeters: _asDouble(map['check_in_distance_meters']),
      checkInWithinGeofence: _asBool(map['check_in_within_geofence']),
      checkInQrValue: map['check_in_qr_value'] as String?,
      previousTopic: map['previous_topic'] as String?,
      expectedTopic: map['expected_topic'] as String?,
      moodBeforeClass: _asInt(map['mood_before_class']),
      finishAt: _parseDateTime(map['finish_at']),
      finishLatitude: _asDouble(map['finish_latitude']),
      finishLongitude: _asDouble(map['finish_longitude']),
      finishAccuracyMeters: _asDouble(map['finish_accuracy_meters']),
      finishDistanceMeters: _asDouble(map['finish_distance_meters']),
      finishWithinGeofence: _asBool(map['finish_within_geofence']),
      finishQrValue: map['finish_qr_value'] as String?,
      learnedToday: map['learned_today'] as String?,
      classFeedback: map['class_feedback'] as String?,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    return DateTime.parse(value.toString());
  }

  static double? _asDouble(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  static int? _asInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }

  static bool? _asBool(Object? value) {
    final intValue = _asInt(value);
    if (intValue == null) {
      return null;
    }
    return intValue == 1;
  }
}
