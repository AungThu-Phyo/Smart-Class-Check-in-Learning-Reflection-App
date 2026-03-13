import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/check_in_record.dart';
import '../models/completion_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentId = auth.appUser?.uid ?? '';
    final firestoreService = FirestoreService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My History'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.login_outlined), text: 'Check-ins'),
              Tab(
                  icon: Icon(Icons.check_circle_outline),
                  text: 'Completions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CheckInHistory(
              studentId: studentId,
              firestoreService: firestoreService,
            ),
            _CompletionHistory(
              studentId: studentId,
              firestoreService: firestoreService,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckInHistory extends StatelessWidget {
  final String studentId;
  final FirestoreService firestoreService;

  const _CheckInHistory({
    required this.studentId,
    required this.firestoreService,
  });

  static const List<String> _moodEmoji = ['', '😡', '🙁', '😐', '🙂', '😄'];
  static const List<String> _moodLabel = [
    '',
    'Very negative',
    'Negative',
    'Neutral',
    'Positive',
    'Very positive',
  ];

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      return const Center(child: Text('Not signed in.'));
    }
    return StreamBuilder<List<CheckInRecord>>(
      stream: firestoreService.watchStudentCheckIns(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No check-ins yet.', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final r = records[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(_moodEmoji[r.moodScore]),
                ),
                title: Text(r.classSessionId),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        DateFormat('MMM d, y  h:mm a').format(r.timestamp)),
                    Text('Mood: ${_moodLabel[r.moodScore]}'),
                    Text('Expected: ${r.expectedTopic}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}

class _CompletionHistory extends StatelessWidget {
  final String studentId;
  final FirestoreService firestoreService;

  const _CompletionHistory({
    required this.studentId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      return const Center(child: Text('Not signed in.'));
    }
    return StreamBuilder<List<CompletionRecord>>(
      stream: firestoreService.watchStudentCompletions(studentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No completions yet.',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final r = records[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.check_circle_outline)),
                title: Text(r.classSessionId),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        DateFormat('MMM d, y  h:mm a').format(r.timestamp)),
                    Text('Learned: ${r.learnedToday}'),
                    if (r.feedback.isNotEmpty) Text('Feedback: ${r.feedback}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }
}
