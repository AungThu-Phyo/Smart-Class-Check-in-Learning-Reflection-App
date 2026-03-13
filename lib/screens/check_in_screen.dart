import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/attendance_record.dart';
import '../models/class_session.dart';
import '../services/firebase_attendance_sync_service.dart';
import '../services/location_service.dart';
import '../services/qr_service.dart';
import '../widgets/session_form_widgets.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({
    super.key,
    required this.session,
    required this.existingRecord,
  });

  final ClassSession session;
  final AttendanceRecord? existingRecord;

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  final _qrController = TextEditingController();
  final LocalDatabase _localDatabase = LocalDatabase.instance;
  final FirebaseAttendanceSyncService _firebaseSyncService =
      FirebaseAttendanceSyncService();
  final LocationService _locationService = LocationService();
  final QrService _qrService = QrService();

  LocationSnapshot? _location;
  int _mood = 3;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _previousTopicController.text = widget.existingRecord?.previousTopic ?? '';
    _expectedTopicController.text = widget.existingRecord?.expectedTopic ?? '';
    _qrController.text = widget.existingRecord?.checkInQrValue ?? '';
    _mood = widget.existingRecord?.moodBeforeClass ?? 3;
  }

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
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
        builder: (_) => const QrScannerScreen(title: 'Scan Check-in QR'),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _qrController.text = result;
    });
  }

  Future<void> _saveCheckIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_location == null) {
      _showSnackBar('Capture GPS location before saving.');
      return;
    }

    if (!_qrService.matches(
      scannedValue: _qrController.text,
      expectedValue: widget.session.startQrToken,
    )) {
      _showSnackBar('Invalid check-in QR value.');
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

    final record = (widget.existingRecord ??
            AttendanceRecord(
              id: 'demo-student-${widget.session.id}',
              sessionId: widget.session.id,
              classTitle: widget.session.classTitle,
              sessionDate: widget.session.sessionDate,
              status: 'none',
            ))
        .copyWith(
      status: 'checked_in',
      checkInAt: DateTime.now(),
      checkInLatitude: _location!.latitude,
      checkInLongitude: _location!.longitude,
      checkInAccuracyMeters: _location!.accuracyMeters,
      checkInDistanceMeters: distanceMeters,
      checkInWithinGeofence: distanceMeters <= widget.session.geofenceRadiusMeters,
      checkInQrValue: _qrController.text.trim(),
      previousTopic: _previousTopicController.text.trim(),
      expectedTopic: _expectedTopicController.text.trim(),
      moodBeforeClass: _mood,
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
      appBar: AppBar(title: const Text('Check-in Screen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SessionIntroCard(
                title: widget.session.classTitle,
                subtitle: 'Record your attendance before class begins.',
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
                  labelText: 'Check-in QR value',
                  suffixIcon: IconButton(
                    onPressed: _scanQr,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'QR value is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _previousTopicController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'What topic was covered in the previous class?',
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _expectedTopicController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'What topic do you expect to learn today?',
                ),
                validator: _requiredText,
              ),
              const SizedBox(height: 16),
              Text(
                'Mood Before Class',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(5, (index) {
                  final moodValue = index + 1;
                  final labels = ['Very negative', 'Negative', 'Neutral', 'Positive', 'Very positive'];
                  return ChoiceChip(
                    label: Text('$moodValue - ${labels[index]}'),
                    selected: _mood == moodValue,
                    onSelected: (_) {
                      setState(() {
                        _mood = moodValue;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _saveCheckIn,
                  child: Text(_saving ? 'Saving...' : 'Save Check-in'),
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
