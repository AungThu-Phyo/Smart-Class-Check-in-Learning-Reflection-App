import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/class_session.dart';
import '../models/check_in_record.dart';
import '../models/completion_record.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import '../widgets/class_card.dart';
import 'check_in_screen.dart';
import 'completion_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'History',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${user.displayName} 👋',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Student ID: ${user.studentId}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<ClassSession>>(
              stream: firestoreService.watchClassSessions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading classes:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final sessions = snapshot.data ?? [];
                if (sessions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No classes scheduled.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    return _ClassCardWrapper(
                      session: session,
                      studentId: user?.uid ?? '',
                      firestoreService: firestoreService,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassCardWrapper extends StatelessWidget {
  final ClassSession session;
  final String studentId;
  final FirestoreService firestoreService;

  const _ClassCardWrapper({
    required this.session,
    required this.studentId,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    if (studentId.isEmpty) {
      return ClassCard(session: session);
    }

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        firestoreService.getCheckInForSession(
          studentId: studentId,
          classSessionId: session.id,
        ),
        firestoreService.getCompletionForSession(
          studentId: studentId,
          classSessionId: session.id,
        ),
      ]),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final checkIn = data != null ? data[0] as CheckInRecord? : null;
        final completion = data != null ? data[1] as CompletionRecord? : null;

        return ClassCard(
          session: session,
          isCheckedIn: checkIn != null,
          isCompleted: completion != null,
          onCheckIn: checkIn == null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheckInScreen(session: session),
                    ),
                  )
              : null,
          onFinishClass: checkIn != null && completion == null
              ? () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompletionScreen(session: session),
                    ),
                  )
              : null,
        );
      },
    );
  }
}
