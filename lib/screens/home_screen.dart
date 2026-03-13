import 'package:flutter/material.dart';

import '../data/local_database.dart';
import '../models/attendance_record.dart';
import '../models/class_session.dart';
import '../services/firebase_bootstrap.dart';
import '../services/session_repository.dart';
import 'check_in_screen.dart';
import 'finish_class_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionRepository _sessionRepository = SessionRepository();
  final LocalDatabase _localDatabase = LocalDatabase.instance;

  late final ClassSession _session;
  AttendanceRecord? _record;
  List<AttendanceRecord> _history = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _session = _sessionRepository.todaySession();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
    });

    final record = await _localDatabase.fetchRecordForSession(_session.id);
    final history = await _localDatabase.fetchAllRecords();

    if (!mounted) {
      return;
    }

    setState(() {
      _record = record;
      _history = history;
      _loading = false;
    });
  }

  Future<void> _openCheckIn() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CheckInScreen(
          session: _session,
          existingRecord: _record,
        ),
      ),
    );

    if (saved == true) {
      await _loadData();
    }
  }

  Future<void> _openFinishClass() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FinishClassScreen(
          session: _session,
          existingRecord: _record,
        ),
      ),
    );

    if (saved == true) {
      await _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _record?.status ?? 'none';
    final canCheckIn = _record?.isCheckedIn != true;
    final canFinish = _record?.isCheckedIn == true && _record?.isCompleted != true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Class Check-in'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _HeroCard(
                    session: _session,
                    status: status,
                    qrHint: _sessionRepository.demoQrHint(),
                  ),
                  const SizedBox(height: 16),
                  _FirebaseStatusCard(
                    isReady: FirebaseBootstrap.isReady,
                    lastError: FirebaseBootstrap.lastError,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: canCheckIn ? _openCheckIn : null,
                          icon: const Icon(Icons.login_rounded),
                          label: const Text('Check-in'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: canFinish ? _openFinishClass : null,
                          icon: const Icon(Icons.task_alt_rounded),
                          label: const Text('Finish Class'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Saved Records',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (_history.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No attendance record has been saved yet. Use Check-in to create your first record.',
                        ),
                      ),
                    )
                  else
                    ..._history.map(_HistoryCard.new),
                ],
              ),
            ),
    );
  }
}

class _FirebaseStatusCard extends StatelessWidget {
  const _FirebaseStatusCard({
    required this.isReady,
    required this.lastError,
  });

  final bool isReady;
  final String? lastError;

  @override
  Widget build(BuildContext context) {
    final normalizedError = (lastError ?? '').toLowerCase();
    final hasMissingAuthConfig =
      normalizedError.contains('configuration_not_found') ||
        normalizedError.contains('configuration-not-found');
    final hasAdminOnlyOperation =
      normalizedError.contains('admin_only_operation') ||
        normalizedError.contains('admin-only-operation');

    final title = isReady ? 'Firebase sync is ready' : 'Firebase sync is not configured yet';
    final body = isReady
        ? 'New attendance records will be saved to SQLite and mirrored to Cloud Firestore.'
        : 'Local SQLite saving still works. After FlutterFire setup, Firestore sync will start automatically.';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(body),
            if (!isReady && hasMissingAuthConfig) ...[
              const SizedBox(height: 8),
              const Text(
                'Action: In Firebase Console, enable Authentication and turn on Anonymous sign-in for this project.',
              ),
            ],
            if (!isReady && hasAdminOnlyOperation) ...[
              const SizedBox(height: 8),
              const Text(
                'Action: This project is set to admin-only account operations. In Firebase Authentication settings, allow end-user sign-up, and keep Anonymous provider enabled.',
              ),
            ],
            if (!isReady && lastError != null && lastError!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Current init message: $lastError',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.session,
    required this.status,
    required this.qrHint,
  });

  final ClassSession session;
  final String status;
  final String qrHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0B6E4F), Color(0xFF157A6E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.classTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Room: ${session.roomName}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Check-in window: ${_formatTime(session.checkInWindowStart)} - ${_formatTime(session.checkInWindowEnd)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Finish window: ${_formatTime(session.finishWindowStart)} - ${_formatTime(session.finishWindowEnd)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                qrHint,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'checked_in' => 'Checked In',
      'completed' => 'Completed',
      _ => 'Not Checked In',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard(this.record);

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    record.classTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(record.status.replaceAll('_', ' ')),
              ],
            ),
            const SizedBox(height: 8),
            Text('Check-in: ${_formatDateTime(record.checkInAt)}'),
            Text('Finish: ${_formatDateTime(record.finishAt)}'),
            Text(
              'GPS status: ${_formatGeofence(record.checkInWithinGeofence, record.finishWithinGeofence)}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Not submitted';
    }

    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month/${value.year} $hour:$minute';
  }

  static String _formatGeofence(bool? checkIn, bool? finish) {
    final checkInLabel = checkIn == null ? 'n/a' : (checkIn ? 'inside' : 'outside');
    final finishLabel = finish == null ? 'n/a' : (finish ? 'inside' : 'outside');
    return 'check-in $checkInLabel, finish $finishLabel';
  }
}
