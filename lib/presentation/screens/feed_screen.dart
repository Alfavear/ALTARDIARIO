import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../../data/models/comment.dart';
import '../../data/models/reflexion.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/guest_access_restricted_widget.dart';
import 'public_profile_screen.dart';
import 'publicar_reflexion_screen.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  String _selectedTag = 'Todo';
  final List<String> _tags = [
    'Todo',
    'Esperanza',
    'Gratitud',
    'Perdón',
    'Amor',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Reflexion> _filterReflexiones(List<Reflexion> reflexiones) {
    var filtered = reflexiones;
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((r) => r.texto.toLowerCase().contains(query))
          .toList();
    }
    if (_selectedTag != 'Todo') {
      final tag = _selectedTag.toLowerCase();
      filtered = filtered
          .where((r) => r.tags.any((t) => t.toLowerCase() == tag))
          .toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isGuest = ref.watch(isGuestUserProvider);

    if (isGuest) {
      return Scaffold(
        backgroundColor: AppTheme.scaffoldBg,
        appBar: AppBar(
          backgroundColor: AppTheme.scaffoldBg,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0,
          title: Row(
            children: [
              const Icon(Icons.menu_book,
                  color: AppTheme.primaryBlue, size: 22),
              const SizedBox(width: 8),
              Text('Altar Comunitario',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppTheme.primaryBlue, fontSize: 20)),
            ],
          ),
        ),
        body: const GuestAccessRestrictedWidget(
          title: 'Altar Comunitario Reservado',
          description:
              'Para proteger la comunidad de perfiles falsos y vulnerabilidades, la lectura y publicación de reflexiones comunitarias están reservadas para miembros registrados con su cuenta de Google.',
        ),
      );
    }

    final reflexionesAsync = ref.watch(reflexionesStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBg,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            const Icon(Icons.menu_book,
                color: AppTheme.primaryBlue, size: 22),
            const SizedBox(width: 8),
            Text('Altar Comunitario',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppTheme.primaryBlue, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: reflexionesAsync.when(
              data: (reflexiones) {
                final filtered = _filterReflexiones(reflexiones);
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.refresh(reflexionesStreamProvider.future),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _ReflexionCard(
                        reflexion: filtered[index]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => const PublicarReflexionScreen(pasajeDia: ''),
          ));
        },
        child: const Icon(Icons.edit, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.pendingGrayDark),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.search,
                    size: 20, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Buscar reflexiones o temas...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(
                        fontSize: 14, fontFamily: 'Inter'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    child: const Icon(Icons.clear,
                        size: 18, color: AppTheme.textSecondary),
                  ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.tune,
                      size: 18, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _tags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final tag = _tags[i];
                final selected = tag == _selectedTag;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTag = tag),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primaryBlue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryBlue
                            : AppTheme.pendingGrayDark,
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
                color: AppTheme.accentGoldLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rss_feed,
                  size: 40, color: AppTheme.accentGold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no hay reflexiones',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Sé el primero en compartir tu devocional!',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
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
    final isSelf = uid == reflexion.userId;
    final isFollowingAsync = uid != null && !isSelf
        ? ref.watch(isFollowingProvider(reflexion.userId))
        : null;
    final userReaction =
        uid != null ? reflexion.getReaction(uid) : null;
    final commentCount = reflexion.commentCount;

    final authorProfile =
        ref.watch(userProfileByIdProvider(reflexion.userId)).value;
    final authorName = (authorProfile?.nombre.isNotEmpty == true)
        ? authorProfile!.displayName
        : reflexion.userName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(
                          userId: reflexion.userId,
                          fallbackName: authorName),
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppTheme.primaryBlue.withValues(alpha: 0.12),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicProfileScreen(
                            userId: reflexion.userId),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary)),
                      Text(
                        _formatTime(reflexion.fecha),
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              if (isFollowingAsync != null)
                isFollowingAsync.when(
                  data: (isFollowing) => GestureDetector(
                        onTap: () async {
                          await ref.read(firestoreServiceProvider).toggleFollow(
                                uid!,
                                reflexion.userId,
                                isFollowing,
                              );
                          ref.invalidate(isFollowingProvider(reflexion.userId));
                        },
                        child: isFollowing
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.todayHighlight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppTheme.completedGreen.withValues(alpha: 0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check,
                                        size: 12, color: AppTheme.completedGreen),
                                    SizedBox(width: 3),
                                    Text('Siguiendo',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.completedGreen)),
                                  ],
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('Seguir',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white)),
                              ),
                      ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.todayHighlight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 14,
                          color: AppTheme.streakOrange,
                          fill: 1),
                      const SizedBox(width: 4),
                      const Text('Tú',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.streakOrange)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlueLight.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_stories,
                    size: 16, color: AppTheme.primaryBlue),
                const SizedBox(width: 4),
                Text(
                  reflexion.pasajeDia,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            reflexion.texto,
            style: const TextStyle(
                fontSize: 14, height: 1.5, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          _ReactionStrip(
            reflexionId: reflexion.id,
            currentReaction: userReaction,
            reactions: reflexion.reactions,
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.pendingGrayDark),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActionBtn(
                icon: Icons.favorite,
                label: 'Amén (${reflexion.likes})',
                isActive: uid != null && reflexion.isLikedBy(uid),
                activeColor: Colors.red,
                onTap: () {
                  if (uid == null) return;
                  final isLiked = reflexion.isLikedBy(uid);
                  ref
                      .read(firestoreServiceProvider)
                      .toggleLike(reflexion.id, uid, isLiked);
                },
              ),
              _ActionBtn(
                icon: Icons.chat_bubble_outline,
                label: 'Comentar (${commentCount > 0 ? '$commentCount' : ''})',
                onTap: () => _showCommentsSheet(context, ref, reflexion),
              ),
              _ActionBtn(
                icon: Icons.share,
                label: 'Compartir',
                onTap: () {
                  final text =
                      '${reflexion.pasajeDia}\n\n${reflexion.texto}\n\n— ${reflexion.userName}';
                  Clipboard.setData(ClipboardData(text: text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('¡Copiado al portapapeles!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(
      BuildContext context, WidgetRef ref, Reflexion r) {
    final uid = ref.read(effectiveUserUidProvider);
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Column(
              children: [
                const Text('Comentarios',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: ref.watch(comentariosStreamProvider(r.id)).when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Center(
                          child: Text('Sin comentarios aún.',
                              style: TextStyle(
                                  color: AppTheme.textSecondary)),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        itemCount: comments.length,
                        itemBuilder: (_, i) =>
                            _CommentTile(comment: comments[i]),
                      );
                    },
                    loading: () => const Center(
                        child: CircularProgressIndicator()),
                    error: (e, _) =>
                        Center(child: Text('Error: $e')),
                  ),
                ),
                if (uid != null)
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                        16, 8, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentCtrl,
                              decoration: InputDecoration(
                                hintText: 'Escribe un comentario...',
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(24),
                                  borderSide: BorderSide(
                                      color:
                                          AppTheme.pendingGrayDark),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                isDense: true,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) {
                                if (value.trim().isEmpty) return;
                                _sendComment(ref, r, uid, value);
                                commentCtrl.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded,
                                color: AppTheme.primaryBlue),
                            onPressed: () {
                              if (commentCtrl.text.trim().isEmpty) {
                                Navigator.pop(ctx);
                                return;
                              }
                              _sendComment(ref, r, uid,
                                  commentCtrl.text);
                              commentCtrl.clear();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendComment(
      WidgetRef ref, Reflexion r, String uid, String text) {
    final user = ref.read(userProfileProvider).value;
    ref.read(firestoreServiceProvider).publicarComentario(
      Comment(
        id: '',
        reflexionId: r.id,
        userId: uid,
        userName: user?.displayName ?? '',
        userFotoUrl: user?.fotoUrl ?? '',
        texto: text.trim(),
        fecha: DateTime.now(),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return DateFormat('dd MMM').format(date);
  }
}

class _CommentTile extends ConsumerWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    final isLiked = comment.isLikedBy(uid ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PublicProfileScreen(
                      userId: comment.userId,
                      fallbackName: comment.userName),
                ),
              );
            },
            child: CircleAvatar(
              radius: 16,
              backgroundColor:
                  AppTheme.primaryBlue.withValues(alpha: 0.12),
              backgroundImage: comment.userFotoUrl.isNotEmpty
                  ? NetworkImage(comment.userFotoUrl)
                  : null,
              child: Text(comment.userName.isNotEmpty
                      ? comment.userName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.scaffoldBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PublicProfileScreen(
                                  userId: comment.userId,
                                  fallbackName: comment.userName),
                            ),
                          );
                        },
                        child: Text(comment.userName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                      const Spacer(),
                      Text(
                        _formatCommentTime(comment.fecha),
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(comment.texto,
                      style: const TextStyle(
                          fontSize: 14, height: 1.3)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      if (uid == null) return;
                      ref
                          .read(firestoreServiceProvider)
                          .toggleCommentLike(comment.reflexionId,
                              comment.id, uid, isLiked);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 14,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                        if (comment.likes > 0) ...[
                          const SizedBox(width: 3),
                          Text('${comment.likes}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isLiked
                                      ? Colors.red
                                      : Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCommentTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return DateFormat('d MMM').format(date);
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
              await ref.read(firestoreServiceProvider).toggleReaction(
                  reflexionId, uid, e, currentReaction);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive
                      ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                '$e${count > 0 ? ' $count' : ''}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive
                ? (activeColor ?? AppTheme.primaryBlue)
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? (activeColor ?? AppTheme.primaryBlue)
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
