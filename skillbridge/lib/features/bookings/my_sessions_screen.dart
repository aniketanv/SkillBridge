import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/bookings/booking_repository.dart';
import 'package:skillbridge/models/booking_model.dart';
import 'package:intl/intl.dart';

class MySessionsScreen extends ConsumerStatefulWidget {
  const MySessionsScreen({super.key});

  @override
  ConsumerState<MySessionsScreen> createState() => _MySessionsScreenState();
}

class _MySessionsScreenState extends ConsumerState<MySessionsScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('My Sessions')),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Not logged in'));
          
          final sessionsAsync = ref.watch(mySessionsProvider(user.id));
          
          return sessionsAsync.when(
            data: (sessions) {
              if (sessions.isEmpty) {
                return const Center(child: Text('No sessions yet.'));
              }
              
              // Split into roles
              final learning = sessions.where((s) => s.learnerId == user.id).toList();
              final teaching = sessions.where((s) => s.teacherId == user.id).toList();

              return DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Learning'),
                        Tab(text: 'Teaching'),
                      ]
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildSessionList(learning, user.id, isTeacher: false),
                          _buildSessionList(teaching, user.id, isTeacher: true),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSessionList(List<BookingModel> sessions, String myUserId, {required bool isTeacher}) {
    if (sessions.isEmpty) return const Center(child: Text('No sessions.'));
    
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(session.dateTime);
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text('Skill ID: ${session.skillId}'), // Ideally lookup title
            subtitle: Text('Status: ${session.status.toUpperCase()}\nDate: $dateStr'),
            trailing: isTeacher && session.status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => ref.read(bookingRepositoryProvider).acceptSession(session),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => ref.read(bookingRepositoryProvider).rejectSession(session),
                      )
                    ],
                  )
                : isTeacher && session.status == 'accepted' 
                  ? TextButton(
                      child: const Text('Mark Completed'),
                      onPressed: () => ref.read(bookingRepositoryProvider).completeSession(session),
                    )
                  : Chip(label: Text('${session.creditAmount} Credits')),
          ),
        );
      },
    );
  }
}
