import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart'; // Correcto
import '../../data/models/reflexion.dart';
import '../../core/theme/app_theme.dart';
import 'chat_screen.dart';
import 'chat_list_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflexionesAsync = ref.watch(reflexionesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Altar Comunitario'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Mensajes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListScreen()),
              );
            },
          ),
        ],
      ),
      body: reflexionesAsync.when(
        data: (reflexiones) => reflexiones.isEmpty
            ? const Center(child: Text('Aún no hay reflexiones hoy. ¡Sé el primero!'))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(reflexionesStreamProvider.future),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: reflexiones.length,
                  itemBuilder: (context, index) => _ReflexionCard(reflexion: reflexiones[index]),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar el feed: $err')),
      ),
    );
  }
}

class _ReflexionCard extends ConsumerWidget {
  final Reflexion reflexion;
  const _ReflexionCard({required this.reflexion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = ref.watch(effectiveUserUidProvider);

    final uid = currentUid;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(reflexion.userName, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                Text(
                  DateFormat('HH:mm').format(reflexion.fecha),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(4)),
              child: Text(reflexion.pasajeDia, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 12),
            Text(reflexion.texto, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    reflexion.isLikedBy(uid ?? '')
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: reflexion.isLikedBy(uid ?? '')
                        ? AppTheme.streakOrange
                        : AppTheme.textSecondary,
                  ),
                  onPressed: () {
                    if (uid == null) return;
                    final isLiked = reflexion.isLikedBy(uid);
                    ref.read(firestoreServiceProvider).toggleLike(reflexion.id, uid, isLiked);
                  },
                ),
                const SizedBox(width: 4),
                Text('${reflexion.likes}', style: const TextStyle(color: AppTheme.textSecondary)),
                const Spacer(),
                if (uid != null && uid != reflexion.userId)
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline, size: 20, color: AppTheme.primaryBlue),
                    onPressed: () {
                      final ids = [uid, reflexion.userId]..sort();
                      final chatId = ids.join('_');
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            otherUserId: reflexion.userId,
                            otherUserName: reflexion.userName,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}