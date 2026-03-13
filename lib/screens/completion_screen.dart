import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_session.dart';
import '../providers/auth_provider.dart';
import '../providers/check_in_provider.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

/// Multi-step Class Completion screen (after class):
///   1. Student scans QR code
///   2. GPS location is recorded
///   3. Student fills post-class reflection form
class CompletionScreen extends StatefulWidget {
  final ClassSession session;

  const CompletionScreen({super.key, required this.session});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _learnedController = TextEditingController();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _learnedController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _startCompletion() async {
    final provider = context.read<CheckInProvider>();
    provider.reset();
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

    final provider = context.read<CheckInProvider>();
    provider.setScannedQrCode(result);

    // Fetch location after QR scan; go directly to form on success
    final success = await provider.fetchLocationAfterQr();
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Could not get location.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final provider = context.read<CheckInProvider>();
    final studentId = auth.appUser?.uid ?? '';

    final success = await provider.submitCompletion(
      studentId: studentId,
      classSessionId: widget.session.id,
      learnedToday: _learnedController.text.trim(),
      feedback: _feedbackController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Class completed! Great work!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Failed to save completion.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: Consumer<CheckInProvider>(
        builder: (context, provider, _) {
          return switch (provider.step) {
            CheckInStep.idle => _IdleView(
                session: widget.session,
                onStart: _startCompletion,
              ),
            CheckInStep.qrScan => _QRScanView(
                session: widget.session,
                onScan: _openQRScanner,
              ),
            CheckInStep.locating => const _LoadingView(
                message: '📍 Getting your location…',
              ),
            CheckInStep.form => _FormView(
                session: widget.session,
                provider: provider,
                formKey: _formKey,
                learnedController: _learnedController,
                feedbackController: _feedbackController,
                onSubmit: _submit,
              ),
            CheckInStep.submitting => const _LoadingView(
                message: '💾 Saving your reflection…',
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
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
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
          const SizedBox(height: 40),
          const Text(
            'When you tap "Finish Class", the app will:\n'
            '  1. Ask you to scan the class QR code\n'
            '  2. Record your GPS location\n'
            '  3. Collect your post-class reflection',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Finish Class'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
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
          const Icon(Icons.qr_code_scanner, size: 80, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Scan the QR code to confirm\nend of ${session.name}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Open QR Scanner'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
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
  final TextEditingController learnedController;
  final TextEditingController feedbackController;
  final VoidCallback onSubmit;

  const _FormView({
    required this.session,
    required this.provider,
    required this.formKey,
    required this.learnedController,
    required this.feedbackController,
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
              'Post-Class Reflection',
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
              const _InfoChip(
                icon: Icons.qr_code,
                label: 'QR scanned ✓',
                color: Colors.blue,
              ),
            const SizedBox(height: 24),
            TextFormField(
              controller: learnedController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What did you learn today?',
                hintText: 'Summarise the key concepts you learned in this class.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Feedback about the class or instructor',
                hintText: 'Share your thoughts on today\'s class.',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Submit Reflection'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
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
