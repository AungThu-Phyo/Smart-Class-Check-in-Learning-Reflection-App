class ClassSession {
  final String id;
  final String name;
  final String courseCode;
  final String instructorName;
  final String room;
  final DateTime scheduledAt;
  final int durationMinutes;

  const ClassSession({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.instructorName,
    required this.room,
    required this.scheduledAt,
    this.durationMinutes = 90,
  });

  factory ClassSession.fromMap(Map<String, dynamic> map, String id) {
    return ClassSession(
      id: id,
      name: map['name'] as String? ?? '',
      courseCode: map['courseCode'] as String? ?? '',
      instructorName: map['instructorName'] as String? ?? '',
      room: map['room'] as String? ?? '',
      scheduledAt: map['scheduledAt'] != null
          ? DateTime.parse(map['scheduledAt'] as String)
          : DateTime.now(),
      durationMinutes: map['durationMinutes'] as int? ?? 90,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'courseCode': courseCode,
      'instructorName': instructorName,
      'room': room,
      'scheduledAt': scheduledAt.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }
}
