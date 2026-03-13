class ClassSession {
  const ClassSession({
    required this.id,
    required this.classId,
    required this.classTitle,
    required this.roomName,
    required this.sessionDate,
    required this.checkInWindowStart,
    required this.checkInWindowEnd,
    required this.finishWindowStart,
    required this.finishWindowEnd,
    required this.classLatitude,
    required this.classLongitude,
    required this.geofenceRadiusMeters,
    required this.startQrToken,
    required this.finishQrToken,
  });

  final String id;
  final String classId;
  final String classTitle;
  final String roomName;
  final DateTime sessionDate;
  final DateTime checkInWindowStart;
  final DateTime checkInWindowEnd;
  final DateTime finishWindowStart;
  final DateTime finishWindowEnd;
  final double classLatitude;
  final double classLongitude;
  final double geofenceRadiusMeters;
  final String startQrToken;
  final String finishQrToken;
}
