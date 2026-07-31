import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/notification.dart';
import '../providers/app_providers.dart';
import 'public_profile_screen.dart';
import 'debate_detail_screen.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    final isGuest = ref.watch(isGuestUserProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    if (isGuest) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        appBar: AppBar(
          title: const Text('Notificaciones'),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
        ),
        body: const Center(
          child: Text('Regístrate para ver tus notificaciones.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todas como leídas',
            onPressed: () {
              if (uid != null) {
                ref.read(firestoreServiceProvider).markAllNotificationsAsRead(uid);
              }
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return _EmptyState();
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsStreamProvider.future),
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return _NotificationTile(notif: notif, uid: uid!);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No tienes notificaciones aún',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notif;
  final String uid;

  const _NotificationTile({required this.notif, required this.uid});

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (!notif.read) {
      ref.read(firestoreServiceProvider).markNotificationAsRead(uid, notif.id);
    }

    if (notif.type == 'new_follower' && notif.actorId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PublicProfileScreen(userId: notif.actorId!),
        ),
      );
    } else if (notif.type == 'debate_reply' && notif.data['debateId'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DebateDetailScreen(debateId: notif.data['debateId']!),
        ),
      );
    }
    // Añadir más redirecciones si es necesario
  }

  IconData _getIcon() {
    switch (notif.type) {
      case 'new_follower':
        return Icons.person_add;
      case 'new_comment':
        return Icons.comment;
      case 'debate_reply':
        return Icons.forum;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor() {
    switch (notif.type) {
      case 'new_follower':
        return Colors.blue;
      case 'new_comment':
        return Colors.orange;
      case 'debate_reply':
        return Colors.purple;
      default:
        return AppTheme.primaryBlue;
    }
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} m';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
    return DateFormat('d MMM').format(time);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: notif.read ? Colors.transparent : AppTheme.primaryBlue.withValues(alpha: 0.05),
      child: ListTile(
        onTap: () => _handleTap(context, ref),
        leading: CircleAvatar(
          backgroundColor: _getIconColor().withValues(alpha: 0.1),
          backgroundImage: notif.actorFotoUrl != null && notif.actorFotoUrl!.isNotEmpty
              ? NetworkImage(notif.actorFotoUrl!)
              : null,
          child: Icon(_getIcon(), color: _getIconColor(), size: 20),
        ),
        title: Text(
          notif.title,
          style: TextStyle(
            fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notif.body, style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(
              _formatTime(notif.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: notif.read
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
