import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/attendance_record.dart';
import '../models/class_session.dart';
import '../services/firebase_attendance_sync_service.dart';
import '../services/location_service.dart';
import '../services/qr_service.dart';
import '../widgets/session_form_widgets.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({
    super.key,
    required this.session,
    required this.existingRecord,
  });

  final ClassSession session;
  final AttendanceRecord? existingRecord;

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _qrController = TextEditingController();
  final LocalDatabase _localDatabase = LocalDatabase.instance;
  final FirebaseAttendanceSyncService _firebaseSyncService =
      FirebaseAttendanceSyncService();
  final LocationService _locationService = LocationService();
  final QrService _qrService = QrService();

  LocationSnapshot? _location;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _learnedTodayController.text = widget.existingRecord?.learnedToday ?? '';
    _feedbackController.text = widget.existingRecord?.classFeedback ?? '';
    _qrController.text = widget.existingRecord?.finishQrValue ?? '';
  }

  @override
  void dispose() {
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    _qrController.dispose();
    super.dispose();
  }

  Future<void> _captureLocation() async {
    try {
      final snapshot = await _locationService.captureCurrentLocation();
      if (!mounted) {
        return;
      }
      setState(() {
        _location = snapshot;
      });
      _showSnackBar('Location captured successfully.');
    } catch (error) {
      _showSnackBar(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _scanQr() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScannerScreen(title: 'Scan Finish QR'),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _qrController.text = result;
    });
  }

  Future<void> _saveFinishClass() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.existingRecord?.isCheckedIn != true) {
      _showSnackBar('Complete check-in before finishing class.');
      return;
    }

    if (_location == null) {
      _showSnackBar('Capture GPS location before saving.');
      return;
    }

    if (!_qrService.matches(
      scannedValue: _qrController.text,
      expectedValue: widget.session.finishQrToken,
    )) {
      _showSnackBar('Invalid finish-class QR value.');
      return;
    }

    setState(() {
      _saving = true;
    });

    final distanceMeters = _locationService.calculateDistanceMeters(
      fromLatitude: _location!.latitude,
      fromLongitude: _location!.longitude,
      toLatitude: widget.session.classLatitude,
      toLongitude: widget.session.classLongitude,
    );

    final record = widget.existingRecord!.copyWith(
      status: 'completed',
      finishAt: DateTime.now(),
      finishLatitude: _location!.latitude,
      finishLongitude: _location!.longitude,
      finishAccuracyMeters: _location!.accuracyMeters,
      finishDistanceMeters: distanceMeters,
      finishWithinGeofence: distanceMeters <= widget.session.geofenceRadiusMeters,
      finishQrValue: _qrController.text.trim(),
      learnedToday: _learnedTodayController.text.trim(),
      classFeedback: _feedbackController.text.trim(),
    );

    await _localDatabase.saveRecord(record);
    await _firebaseSyncService.syncRecord(record: record, session: widget.session);

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SessionIntroCard(
                title: widget.session.classTitle,
                subtitle: 'Record what happened at the end of the class.',
              ),
              const SizedBox(height: 20),
              LocationStatusCard(
                location: _location,
                onCapture: _captureLocation,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _qrController,
                decoration: InputDecoration(
                  labelText: 'Finish-class QR value',
                  suffixIcon: IconButton(
                    onPressed: _scanQr,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _learnedTodayController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'What did you learn today?',
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Feedback about the class or instructor',
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveFinishClass,
                  child: Text(_saving ? 'Saving...' : 'Save Finish Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().length < 3) {
      return 'Please enter at least 3 characters.';
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
