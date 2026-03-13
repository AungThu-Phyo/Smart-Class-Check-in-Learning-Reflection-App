import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/check_in_record.dart';
import '../models/completion_record.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

enum CheckInStep { idle, locating, qrScan, form, submitting, done }

class CheckInProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  CheckInStep _step = CheckInStep.idle;
  Position? _currentPosition;
  String? _scannedQrCode;
  String? _errorMessage;

  CheckInStep get step => _step;
  Position? get currentPosition => _currentPosition;
  String? get scannedQrCode => _scannedQrCode;
  String? get errorMessage => _errorMessage;

  void reset() {
    _step = CheckInStep.idle;
    _currentPosition = null;
    _scannedQrCode = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetches GPS location. On success the step advances to [CheckInStep.qrScan]
  /// so the user can then scan the QR code (used in the check-in flow).
  Future<bool> fetchLocation() async {
    _step = CheckInStep.locating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      _step = CheckInStep.qrScan;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _step = CheckInStep.idle;
      notifyListeners();
      return false;
    }
  }

  /// Fetches GPS location after a QR code has already been scanned.
  /// On success the step advances directly to [CheckInStep.form]
  /// (used in the completion flow where QR scanning happens first).
  Future<bool> fetchLocationAfterQr() async {
    _step = CheckInStep.locating;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentPosition();
      _step = CheckInStep.form;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _step = CheckInStep.qrScan;
      notifyListeners();
      return false;
    }
  }

  void setScannedQrCode(String qrCode) {
    _scannedQrCode = qrCode;
    _step = CheckInStep.form;
    notifyListeners();
  }

  Future<bool> submitCheckIn({
    required String studentId,
    required String classSessionId,
    required String previousTopic,
    required String expectedTopic,
    required int moodScore,
  }) async {
    if (_currentPosition == null) {
      _errorMessage = 'Location not available. Please try again.';
      notifyListeners();
      return false;
    }

    _step = CheckInStep.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final record = CheckInRecord(
        id: '',
        studentId: studentId,
        classSessionId: classSessionId,
        timestamp: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        previousTopic: previousTopic,
        expectedTopic: expectedTopic,
        moodScore: moodScore,
      );
      await _firestoreService.saveCheckIn(record);
      _step = CheckInStep.done;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save check-in. Please try again.';
      _step = CheckInStep.form;
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitCompletion({
    required String studentId,
    required String classSessionId,
    required String learnedToday,
    required String feedback,
  }) async {
    if (_currentPosition == null) {
      _errorMessage = 'Location not available. Please try again.';
      notifyListeners();
      return false;
    }

    _step = CheckInStep.submitting;
    _errorMessage = null;
    notifyListeners();

    try {
      final record = CompletionRecord(
        id: '',
        studentId: studentId,
        classSessionId: classSessionId,
        timestamp: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        learnedToday: learnedToday,
        feedback: feedback,
      );
      await _firestoreService.saveCompletion(record);
      _step = CheckInStep.done;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save completion. Please try again.';
      _step = CheckInStep.form;
      notifyListeners();
      return false;
    }
  }
}
