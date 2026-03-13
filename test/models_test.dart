import 'package:flutter_test/flutter_test.dart';
import 'package:smart_class_checkin/models/check_in_record.dart';
import 'package:smart_class_checkin/models/completion_record.dart';
import 'package:smart_class_checkin/models/app_user.dart';
import 'package:smart_class_checkin/models/class_session.dart';
import 'package:smart_class_checkin/services/location_service.dart';

void main() {
  group('CheckInRecord', () {
    final now = DateTime(2024, 3, 15, 9, 0);

    test('serialises to map and back correctly', () {
      final record = CheckInRecord(
        id: 'ci-1',
        studentId: 'student-abc',
        classSessionId: 'session-xyz',
        timestamp: now,
        latitude: 1.3521,
        longitude: 103.8198,
        previousTopic: 'Variables',
        expectedTopic: 'Loops',
        moodScore: 4,
      );

      final map = record.toMap();

      expect(map['studentId'], 'student-abc');
      expect(map['classSessionId'], 'session-xyz');
      expect(map['latitude'], closeTo(1.3521, 0.0001));
      expect(map['longitude'], closeTo(103.8198, 0.0001));
      expect(map['previousTopic'], 'Variables');
      expect(map['expectedTopic'], 'Loops');
      expect(map['moodScore'], 4);

      final restored = CheckInRecord.fromMap(map, 'ci-1');
      expect(restored.id, 'ci-1');
      expect(restored.studentId, record.studentId);
      expect(restored.latitude, record.latitude);
      expect(restored.moodScore, record.moodScore);
    });

    test('mood score is within valid range 1–5', () {
      for (final score in [1, 2, 3, 4, 5]) {
        final record = CheckInRecord(
          id: '',
          studentId: 'student',
          classSessionId: 'session',
          timestamp: now,
          latitude: 0,
          longitude: 0,
          previousTopic: '',
          expectedTopic: '',
          moodScore: score,
        );
        expect(record.moodScore, inInclusiveRange(1, 5));
      }
    });
  });

  group('CompletionRecord', () {
    final now = DateTime(2024, 3, 15, 11, 30);

    test('serialises to map and back correctly', () {
      final record = CompletionRecord(
        id: 'comp-1',
        studentId: 'student-abc',
        classSessionId: 'session-xyz',
        timestamp: now,
        latitude: 1.3521,
        longitude: 103.8198,
        learnedToday: 'For loops and while loops',
        feedback: 'Great explanations!',
      );

      final map = record.toMap();

      expect(map['learnedToday'], 'For loops and while loops');
      expect(map['feedback'], 'Great explanations!');

      final restored = CompletionRecord.fromMap(map, 'comp-1');
      expect(restored.id, 'comp-1');
      expect(restored.learnedToday, record.learnedToday);
      expect(restored.feedback, record.feedback);
    });
  });

  group('AppUser', () {
    test('serialises to map and back correctly', () {
      final user = AppUser(
        uid: 'uid-123',
        email: 'student@uni.edu',
        displayName: 'Alice Smith',
        studentId: 'S001',
      );
      final map = user.toMap();
      expect(map['email'], 'student@uni.edu');
      expect(map['displayName'], 'Alice Smith');
      expect(map['studentId'], 'S001');

      final restored = AppUser.fromMap(map, 'uid-123');
      expect(restored.uid, 'uid-123');
      expect(restored.displayName, 'Alice Smith');
    });
  });

  group('ClassSession', () {
    test('serialises to map and back correctly', () {
      final scheduled = DateTime(2024, 3, 15, 9, 0);
      final session = ClassSession(
        id: 'sess-1',
        name: 'Introduction to Programming',
        courseCode: 'CS101',
        instructorName: 'Dr. Lee',
        room: 'Lab 3B',
        scheduledAt: scheduled,
        durationMinutes: 90,
      );
      final map = session.toMap();
      expect(map['courseCode'], 'CS101');
      expect(map['room'], 'Lab 3B');
      expect(map['durationMinutes'], 90);

      final restored = ClassSession.fromMap(map, 'sess-1');
      expect(restored.id, 'sess-1');
      expect(restored.name, session.name);
      expect(restored.durationMinutes, 90);
    });
  });

  group('LocationService.formatPosition', () {
    test('formats northern/eastern position correctly', () {
      final formatted = LocationService.formatPosition(1.3521, 103.8198);
      expect(formatted, '1.3521° N, 103.8198° E');
    });

    test('formats southern/western position correctly', () {
      final formatted = LocationService.formatPosition(-33.8688, -70.6693);
      expect(formatted, '33.8688° S, 70.6693° W');
    });

    test('handles zero position', () {
      final formatted = LocationService.formatPosition(0.0, 0.0);
      expect(formatted, '0.0000° N, 0.0000° E');
    });
  });
}
