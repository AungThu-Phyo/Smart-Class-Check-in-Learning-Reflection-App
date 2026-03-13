import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_session.dart';
import '../providers/auth_provider.dart';
import '../providers/check_in_provider.dart';
import '../services/location_service.dart';
import '../widgets/mood_selector.dart';
import 'qr_scanner_screen.dart';

/// Multi-step Check-in screen:
///   1. GPS location is recorded
///   2. Student scans QR code
///   3. Student fills pre-class reflection form
class CheckInScreen extends StatefulWidget {
  final ClassSession session;

  const CheckInScreen({super.key, required this.session});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  int _moodScore = 3;

  @override
  void dispose() {
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Future<void> _startCheckIn() async {
    final provider = context.read<CheckInProvider>();
    provider.reset();
    final success = await provider.fetchLocation();
    if (!mounted) return;
    if (!success) {
      _showError(provider.errorMessage ?? 'Could not get location.');
      return;
    }
    _openQRScanner();
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );
    if (!mounted) return;
    if (result == null || result.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR scan cancelled.')),
      );
      return;
    }
    context.read<CheckInProvider>().setScannedQrCode(result);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<CheckInProvider>();
    final studentId = auth.appUser?.uid ?? '';

    final success = await provider.submitCheckIn(
      studentId: studentId,
      classSessionId: widget.session.id,
      previousTopic: _previousTopicController.text.trim(),
      expectedTopic: _expectedTopicController.text.trim(),
      moodScore: _moodScore,
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Check-in successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      _showError(provider.errorMessage ?? 'Failed to check in.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: Consumer<CheckInProvider>(
        builder: (context, provider, _) {
          return switch (provider.step) {
            CheckInStep.idle => _IdleView(
                session: widget.session,
                onStart: _startCheckIn,
              ),
            CheckInStep.locating => const _LoadingView(
                message: '📍 Getting your location…',
              ),
            CheckInStep.qrScan => _QRScanView(
                session: widget.session,
                onScan: _openQRScanner,
              ),
            CheckInStep.form => _FormView(
                session: widget.session,
                provider: provider,
                formKey: _formKey,
                previousTopicController: _previousTopicController,
                expectedTopicController: _expectedTopicController,
                moodScore: _moodScore,
                onMoodChanged: (v) => setState(() => _moodScore = v),
                onSubmit: _submit,
              ),
            CheckInStep.submitting => const _LoadingView(
                message: '💾 Saving your check-in…',
              ),
            CheckInStep.done => const _LoadingView(
                message: '✅ Done!',
              ),
          };
        },
      ),
    );
  }
}

// ── Sub-views ────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final ClassSession session;
  final VoidCallback onStart;

  const _IdleView({required this.session, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.login_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            session.name,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            session.courseCode,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            session.room,
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text(
            'When you tap "Check In", the app will:\n'
            '  1. Record your GPS location\n'
            '  2. Ask you to scan the class QR code\n'
            '  3. Collect your pre-class reflection',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.login_outlined),
            label: const Text('Check In'),
          ),
        ],
      ),
    );
  }
}

class _QRScanView extends StatelessWidget {
  final ClassSession session;
  final VoidCallback onScan;

  const _QRScanView({required this.session, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 64, color: Colors.green),
          const SizedBox(height: 8),
          const Text(
            '📍 Location recorded!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 32),
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Scan the QR code for\n${session.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Open QR Scanner'),
          ),
        ],
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final ClassSession session;
  final CheckInProvider provider;
  final GlobalKey<FormState> formKey;
  final TextEditingController previousTopicController;
  final TextEditingController expectedTopicController;
  final int moodScore;
  final ValueChanged<int> onMoodChanged;
  final VoidCallback onSubmit;

  const _FormView({
    required this.session,
    required this.provider,
    required this.formKey,
    required this.previousTopicController,
    required this.expectedTopicController,
    required this.moodScore,
    required this.onMoodChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final pos = provider.currentPosition;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pre-Class Reflection',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              session.name,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            if (pos != null)
              _InfoChip(
                icon: Icons.location_on_outlined,
                label: LocationService.formatPosition(
                    pos.latitude, pos.longitude),
                color: Colors.green,
              ),
            if (provider.scannedQrCode != null)
              _InfoChip(
                icon: Icons.qr_code,
                label: 'QR scanned ✓',
                color: Colors.blue,
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: previousTopicController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What topic was covered in the previous class?',
                hintText: 'e.g. Introduction to variables and data types',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: expectedTopicController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'What topic do you expect to learn today?',
                hintText: 'e.g. Loops and control flow',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            MoodSelector(
              selectedMood: moodScore,
              onMoodSelected: onMoodChanged,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit Check-in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String message;

  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(message, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
