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
    final currentUid = ref.watch(effectiveUserUidProvider);
    final chatsAsync = currentUid != null
        ? ref.watch(chatListProvider(currentUid))
        : const AsyncLoading<List<Map<String, dynamic>>>();

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mensajes',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nueva conversación — próximamente')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opciones — próximamente')),
              );
            },
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return _buildEmptyState();
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildOnlineSection(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recientes',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textSecondary)),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Función de limpiar — próximamente')),
                      );
                    },
                    child: const Text('Limpiar',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.primaryBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ...chats.map((chat) => _buildChatCard(
                  context, ref, chat, currentUid!)),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nuevo chat — próximamente')),
          );
        },
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline,
                  size: 40, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sin conversaciones aún',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Da like a una reflexión y escribe\npara iniciar un chat',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppTheme.softShadow,
      ),
      child: const Row(
        children: [
          Icon(Icons.search,
              size: 20, color: AppTheme.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar conversaciones...',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('En línea ahora',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppTheme.textSecondary)),
        ),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Mateo', 'Lucía', 'Andrés', 'Sofía']
                .map((name) => _OnlineUser(name: name))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChatCard(
      BuildContext context, WidgetRef ref, Map<String, dynamic> chat, String currentUid) {
    final chatId = chat['id'] as String;
    final participantNames =
        chat['participantNames'] as Map<String, dynamic>? ?? {};
    final participantIds =
        chat['participantIds'] as List<dynamic>? ?? [];
    final lastMessage = chat['lastMessage'] as String? ?? '';
    final lastUpdate = chat['lastUpdate'] as dynamic;

    String otherName = 'Usuario';
    String otherId = '';
    for (final pid in participantIds) {
      if (pid.toString() != currentUid) {
        otherId = pid.toString();
        otherName =
            participantNames[otherId]?.toString() ?? 'Usuario';
      }
    }

    String timeAgo = '';
    if (lastUpdate != null) {
      final date = (lastUpdate as dynamic).toDate();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) {
        timeAgo = DateFormat('HH:mm').format(date);
      } else if (diff.inDays == 1) {
        timeAgo = 'Ayer';
      } else {
        timeAgo = DateFormat('dd MMM').format(date);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              otherUserId: otherId,
              otherUserName: otherName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    otherName.isNotEmpty
                        ? otherName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(otherName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppTheme.textPrimary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(timeAgo,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right,
                size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _OnlineUser extends StatelessWidget {
  final String name;
  const _OnlineUser({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor:
                    AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    color: AppTheme.completedGreen,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(BorderSide(
                        color: Colors.white, width: 2)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(name,
              style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
