import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skillbridge/features/auth/auth_repository.dart';
import 'package:skillbridge/features/chat/chat_repository.dart';
import 'package:skillbridge/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

final recentChatsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const Stream.empty();
  return ref.watch(chatRepositoryProvider).getRecentChats(user.id);
});

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentChatsAsync = ref.watch(recentChatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: recentChatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final UserModel? contactUser = chat['contactUser'];
              final String lastMessage = chat['lastMessage'] ?? '';
              
              if (contactUser == null) return const SizedBox.shrink();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  backgroundImage: contactUser.profilePhotoUrl.isNotEmpty 
                      ? CachedNetworkImageProvider(contactUser.profilePhotoUrl) 
                      : null,
                  child: contactUser.profilePhotoUrl.isEmpty 
                      ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary) 
                      : null,
                ),
                title: Text(contactUser.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () {
                  context.push('/chat-detail', extra: contactUser);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
