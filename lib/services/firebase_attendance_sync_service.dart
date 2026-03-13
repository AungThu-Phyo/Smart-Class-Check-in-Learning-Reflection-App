import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/attendance_record.dart';
import '../models/class_session.dart';
import 'firebase_bootstrap.dart';

class FirebaseAttendanceSyncService {
  Future<bool> syncRecord({
    required AttendanceRecord record,
    required ClassSession session,
  }) async {
    if (!FirebaseBootstrap.isReady) {
      return false;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('attendance_records')
          .doc(record.id)
          .set(
        {
          'id': record.id,
          'uid': user?.uid ?? 'anonymous',
          'sessionId': record.sessionId,
          'classId': session.classId,
          'classTitle': record.classTitle,
          'roomName': session.roomName,
          'sessionDate': record.sessionDate.toIso8601String(),
          'status': record.status,
          'source': 'flutter_mvp_sqlite_sync',
          'updatedAt': FieldValue.serverTimestamp(),
          'checkIn': {
            'submittedAt': record.checkInAt?.toIso8601String(),
            'latitude': record.checkInLatitude,
            'longitude': record.checkInLongitude,
            'accuracyMeters': record.checkInAccuracyMeters,
            'distanceMeters': record.checkInDistanceMeters,
            'withinGeofence': record.checkInWithinGeofence,
            'qrValue': record.checkInQrValue,
            'previousTopic': record.previousTopic,
            'expectedTopic': record.expectedTopic,
            'moodBeforeClass': record.moodBeforeClass,
          },
          'finishClass': {
            'submittedAt': record.finishAt?.toIso8601String(),
            'latitude': record.finishLatitude,
            'longitude': record.finishLongitude,
            'accuracyMeters': record.finishAccuracyMeters,
            'distanceMeters': record.finishDistanceMeters,
            'withinGeofence': record.finishWithinGeofence,
            'qrValue': record.finishQrValue,
            'learnedToday': record.learnedToday,
            'classFeedback': record.classFeedback,
          },
        },
        SetOptions(merge: true),
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
