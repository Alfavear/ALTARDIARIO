import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateProvider).value;
    final chatsAsync = currentUser != null
        ? ref.watch(chatListProvider(currentUser.uid))
        : const AsyncLoading<List<Map<String, dynamic>>>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensajes'),
        centerTitle: true,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Sin conversaciones aún',
                    style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Da like a una reflexión y escribe\npara iniciar un chat',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatId = chat['id'] as String;
              final participantNames = chat['participantNames'] as Map<String, dynamic>? ?? {};
              final participantIds = chat['participantIds'] as List<dynamic>? ?? [];
              final lastMessage = chat['lastMessage'] as String? ?? '';
              final lastUpdate = chat['lastUpdate'] as dynamic;

              String otherName = 'Usuario';
              String otherId = '';
              for (final pid in participantIds) {
                if (pid.toString() != currentUser?.uid) {
                  otherId = pid.toString();
                  otherName = participantNames[otherId]?.toString() ?? 'Usuario';
                }
              }

              String timeAgo = '';
              if (lastUpdate != null) {
                final date = (lastUpdate as dynamic).toDate();
                timeAgo = DateFormat('dd/MM').format(date);
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  child: Text(
                    otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  otherName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                trailing: Text(
                  timeAgo,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatId: chatId,
                        otherUserId: otherId,
                        otherUserName: otherName,
                      ),
                    ),
                  );
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
