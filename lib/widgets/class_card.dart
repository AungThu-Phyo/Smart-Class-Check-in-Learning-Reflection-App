import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/class_session.dart';

class ClassCard extends StatelessWidget {
  final ClassSession session;
  final bool isCheckedIn;
  final bool isCompleted;
  final VoidCallback? onCheckIn;
  final VoidCallback? onFinishClass;

  const ClassCard({
    super.key,
    required this.session,
    this.isCheckedIn = false,
    this.isCompleted = false,
    this.onCheckIn,
    this.onFinishClass,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(session.scheduledAt);
    final dateStr = DateFormat('EEE, MMM d').format(session.scheduledAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.courseCode,
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  isCheckedIn: isCheckedIn,
                  isCompleted: isCompleted,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.person_outline, text: session.instructorName),
            _InfoRow(icon: Icons.room_outlined, text: session.room),
            _InfoRow(
              icon: Icons.access_time_outlined,
              text: '$dateStr · $timeStr · ${session.durationMinutes} min',
            ),
            const SizedBox(height: 12),
            _ActionButtons(
              isCheckedIn: isCheckedIn,
              isCompleted: isCompleted,
              onCheckIn: onCheckIn,
              onFinishClass: onFinishClass,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isCheckedIn;
  final bool isCompleted;

  const _StatusBadge({required this.isCheckedIn, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _badge(context, '✅ Done', Colors.green);
    }
    if (isCheckedIn) {
      return _badge(context, '📍 In Class', Colors.blue);
    }
    return _badge(context, '🕐 Upcoming', Colors.grey);
  }

  Widget _badge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isCheckedIn;
  final bool isCompleted;
  final VoidCallback? onCheckIn;
  final VoidCallback? onFinishClass;

  const _ActionButtons({
    required this.isCheckedIn,
    required this.isCompleted,
    required this.onCheckIn,
    required this.onFinishClass,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return const SizedBox.shrink();
    }
    if (isCheckedIn) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onFinishClass,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Finish Class'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onCheckIn,
        icon: const Icon(Icons.login_outlined),
        label: const Text('Check In'),
      ),
    );
  }
}
