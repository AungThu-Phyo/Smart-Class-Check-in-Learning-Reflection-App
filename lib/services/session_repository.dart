import '../models/class_session.dart';

class SessionRepository {
  ClassSession todaySession() {
    final now = DateTime.now();
    final sessionDate = DateTime(now.year, now.month, now.day);

    return ClassSession(
      id: 'session-${sessionDate.toIso8601String().split('T').first}',
      classId: 'CSE-3201',
      classTitle: 'Smart Class Mobile Lab',
      roomName: 'Innovation Lab 2',
      sessionDate: sessionDate,
      checkInWindowStart: now.subtract(const Duration(hours: 1)),
      checkInWindowEnd: now.add(const Duration(hours: 2)),
      finishWindowStart: now.subtract(const Duration(minutes: 10)),
      finishWindowEnd: now.add(const Duration(hours: 6)),
      classLatitude: 16.8409,
      classLongitude: 96.1735,
      geofenceRadiusMeters: 250,
      startQrToken: 'SMART-CLASS-START',
      finishQrToken: 'SMART-CLASS-END',
    );
  }

  String demoQrHint() {
    return 'Use SMART-CLASS-START for check-in and SMART-CLASS-END for finish if a real QR code is not available.';
  }
}
