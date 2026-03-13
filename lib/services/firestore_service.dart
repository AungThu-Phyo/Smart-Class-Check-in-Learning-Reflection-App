import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_session.dart';
import '../models/check_in_record.dart';
import '../models/completion_record.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Class sessions ────────────────────────────────────────────────────────

  Stream<List<ClassSession>> watchClassSessions() {
    return _db
        .collection('classSessions')
        .orderBy('scheduledAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClassSession.fromMap(d.data(), d.id))
            .toList());
  }

  Future<ClassSession?> getClassSessionByQrCode(String qrCode) async {
    final snap = await _db
        .collection('classSessions')
        .where('qrCode', isEqualTo: qrCode)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return ClassSession.fromMap(doc.data(), doc.id);
  }

  // ── Check-in records ──────────────────────────────────────────────────────

  Future<String> saveCheckIn(CheckInRecord record) async {
    final docRef = record.id.isEmpty
        ? _db.collection('checkIns').doc()
        : _db.collection('checkIns').doc(record.id);
    await docRef.set(record.toMap());
    return docRef.id;
  }

  Stream<List<CheckInRecord>> watchStudentCheckIns(String studentId) {
    return _db
        .collection('checkIns')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CheckInRecord.fromMap(d.data(), d.id))
            .toList());
  }

  Future<CheckInRecord?> getCheckInForSession({
    required String studentId,
    required String classSessionId,
  }) async {
    final snap = await _db
        .collection('checkIns')
        .where('studentId', isEqualTo: studentId)
        .where('classSessionId', isEqualTo: classSessionId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return CheckInRecord.fromMap(doc.data(), doc.id);
  }

  // ── Completion records ────────────────────────────────────────────────────

  Future<String> saveCompletion(CompletionRecord record) async {
    final docRef = record.id.isEmpty
        ? _db.collection('completions').doc()
        : _db.collection('completions').doc(record.id);
    await docRef.set(record.toMap());
    return docRef.id;
  }

  Stream<List<CompletionRecord>> watchStudentCompletions(String studentId) {
    return _db
        .collection('completions')
        .where('studentId', isEqualTo: studentId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => CompletionRecord.fromMap(d.data(), d.id))
            .toList());
  }

  Future<CompletionRecord?> getCompletionForSession({
    required String studentId,
    required String classSessionId,
  }) async {
    final snap = await _db
        .collection('completions')
        .where('studentId', isEqualTo: studentId)
        .where('classSessionId', isEqualTo: classSessionId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return CompletionRecord.fromMap(doc.data(), doc.id);
  }
}
