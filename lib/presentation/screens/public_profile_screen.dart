import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reflexion.dart';
import '../../data/models/usuario.dart';
import '../providers/app_providers.dart';
import 'followers_screen.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(otherUserProfileProvider(userId));
    final reflexionesAsync = ref.watch(userReflexionesProvider(userId));
    final uid = ref.watch(effectiveUserUidProvider);
    final isSelf = uid == userId;
    final isFollowingAsync = ref.watch(isFollowingProvider(userId));

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
appBar: AppBar(
  backgroundColor: Colors.white,
  foregroundColor: AppTheme.textPrimary,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text('Perfil',
      style: TextStyle(fontWeight: FontWeight.bold)),
),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildProfileHeader(context, ref, user, isSelf,
                    isFollowingAsync, uid),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Reflexiones de ${user.nombre}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              reflexionesAsync.when(
                data: (reflexiones) => reflexiones.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Text(
                            'Aún no ha publicado reflexiones.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _buildReflexionCard(
                              context, ref, reflexiones[i], uid),
                          childCount: reflexiones.length,
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Error: $e'),
                )),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    Usuario user,
    bool isSelf,
    AsyncValue<bool> isFollowingAsync,
    String? uid,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage:
                    user.fotoUrl.isNotEmpty ? NetworkImage(user.fotoUrl) : null,
                child: user.fotoUrl.isEmpty
                    ? Text(
                        user.nombre.isNotEmpty
                            ? user.nombre[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              Text(user.nombre,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              if (user.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(user.bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
              ],
              const SizedBox(height: 8),
              Text(
                'Miembro desde ${DateFormat('MMM yyyy').format(user.fechaCreacion)}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatColumn(
                      '${user.siguiendo.length}', 'Siguiendo', () {
                    if (user.siguiendo.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowersScreen(
                            userId: userId,
                            tabIndex: 0,
                          ),
                        ),
                      );
                    }
                  }),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  _buildStatColumn(
                      '${user.seguidores.length}', 'Seguidores', () {
                    if (user.seguidores.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FollowersScreen(
                            userId: userId,
                            tabIndex: 1,
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
              if (!isSelf && uid != null) ...[
                const SizedBox(height: 16),
                isFollowingAsync.when(
                  data: (isFollowing) => SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(firestoreServiceProvider)
                            .toggleFollow(uid, userId, isFollowing);
                        ref.invalidate(isFollowingProvider(userId));
                      },
                      icon: Icon(isFollowing
                          ? Icons.person_remove
                          : Icons.person_add),
                      label: Text(isFollowing
                          ? 'Dejar de seguir'
                          : 'Seguir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.white,
                        foregroundColor:
                            isFollowing ? Colors.white : AppTheme.primaryBlue,
                        side: isFollowing
                            ? const BorderSide(color: Colors.white38)
                            : null,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(
      String value, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text(label,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildReflexionCard(
      BuildContext context, WidgetRef ref, Reflexion r, String? uid) {
    final isLiked = r.isLikedBy(uid ?? '');
    final userReaction = uid != null ? r.getReaction(uid) : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r.pasajeDia,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.primaryBlue)),
              ),
              const Spacer(),
              Text(
                DateFormat('d MMM').format(r.fecha),
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(r.texto,
              style: const TextStyle(
                  fontSize: 15, height: 1.4, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              _IconCount(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : AppTheme.textSecondary,
                count: r.likes,
              ),
              const SizedBox(width: 16),
              _IconCount(
                icon: Icons.chat_bubble_outline,
                color: AppTheme.textSecondary,
                count: r.commentCount,
              ),
              const Spacer(),
              _ReactionStrip(
                reflexionId: r.id,
                currentReaction: userReaction,
                reactions: r.reactions,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconCount extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  const _IconCount(
      {required this.icon, required this.color, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text('$count',
            style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}

class _ReactionStrip extends ConsumerWidget {
  final String reflexionId;
  final String? currentReaction;
  final Map<String, String> reactions;
  const _ReactionStrip(
      {required this.reflexionId,
      required this.currentReaction,
      required this.reactions});

  static const _emojis = ['❤️', '🙏', '🔥', '💡'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._emojis.map((e) {
          final isActive = currentReaction == e;
          final count = reactions.values.where((v) => v == e).length;
          return GestureDetector(
            onTap: () async {
              if (uid == null) return;
              await ref
                  .read(firestoreServiceProvider)
                  .toggleReaction(reflexionId, uid, e, currentReaction);
            },
            child: Container(
              margin: const EdgeInsets.only(left: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$e${count > 0 ? ' $count' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        }),
      ],
    );
  }
}
