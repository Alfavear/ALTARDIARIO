import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/debate.dart';
import '../../data/models/debate_reply.dart';
import '../../features/moderation/presentation/report_content_dialog.dart';
import '../providers/app_providers.dart';
import 'public_profile_screen.dart';

class DebateDetailScreen extends ConsumerStatefulWidget {
  final String debateId;
  const DebateDetailScreen({super.key, required this.debateId});

  @override
  ConsumerState<DebateDetailScreen> createState() => _DebateDetailScreenState();
}

class _DebateDetailScreenState extends ConsumerState<DebateDetailScreen> {
  final _replyCtrl = TextEditingController();

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReply(String debateId, String uid, Debate debate) async {
    final text = _replyCtrl.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(userProfileProvider).value;
    await ref.read(firestoreServiceProvider).crearRespuesta(
          DebateReply(
            id: '',
            debateId: debateId,
            userId: uid,
            userName: user?.displayName ?? '',
            texto: text,
            fecha: DateTime.now(),
          ),
        );
    _replyCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(effectiveUserUidProvider);
    final debatesAsync = ref.watch(debatesStreamProvider(null));
    final repliesAsync =
        ref.watch(debateRepliesStreamProvider(widget.debateId));

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
        title:
            const Text('Debate', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: debatesAsync.when(
        data: (debates) {
          final debate =
              debates.where((d) => d.id == widget.debateId).firstOrNull;
          if (debate == null) {
            return const Center(child: Text('Debate no encontrado'));
          }
          final hasVoted = debate.hasVoted(uid ?? '');
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    _DebateHeader(
                      debate: debate,
                      hasVoted: hasVoted,
                      uid: uid,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Text(
                        'Reglas comunitarias: respeta a los demás, evita spam y '
                        'contenido ofensivo. Los debates pueden ser cerrados por '
                        'su autor o moderados.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Respuestas',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                    repliesAsync.when(
                      data: (replies) {
                        if (replies.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'SÃ© el primero en responder.',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          );
                        }
                        final topLevel =
                            replies.where((r) => r.parentId == null).toList();
                        final children = <String, List<DebateReply>>{};
                        for (final r in replies) {
                          if (r.parentId != null) {
                            children.putIfAbsent(r.parentId!, () => []).add(r);
                          }
                        }
                        return Column(
                          children: topLevel.map((r) {
                            final nested = children[r.id] ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ReplyTile(reply: r, uid: uid),
                                ...nested.map((nr) => Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: _ReplyTile(reply: nr, uid: uid),
                                    )),
                              ],
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                  ],
                ),
              ),
              if (uid != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            controller: _replyCtrl,
                            decoration: InputDecoration(
                              hintText: 'Escribe una respuesta...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(
                                    color: AppTheme.pendingGrayDark),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (v) {
                              if (v.trim().isEmpty) return;
                              _sendReply(widget.debateId, uid, debate);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send_rounded,
                              color: AppTheme.primaryBlue),
                          onPressed: () {
                            if (_replyCtrl.text.trim().isEmpty) {
                              return;
                            }
                            _sendReply(widget.debateId, uid, debate);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DebateHeader extends ConsumerWidget {
  final Debate debate;
  final bool hasVoted;
  final String? uid;

  const _DebateHeader({
    required this.debate,
    required this.hasVoted,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(debate.titulo,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (debate.contenido.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(debate.contenido,
                  style: const TextStyle(
                      fontSize: 15, height: 1.4, color: AppTheme.textPrimary)),
            ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(firestoreServiceProvider)
                      .toggleDebateVote(debate.id, uid ?? '', hasVoted);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasVoted
                        ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_drop_up,
                        color: hasVoted
                            ? AppTheme.primaryBlue
                            : AppTheme.textSecondary,
                      ),
                      Text('${debate.upvotes}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: hasVoted
                                  ? AppTheme.primaryBlue
                                  : AppTheme.textPrimary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.chat_bubble_outline,
                  size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text('${debate.replyCount} respuestas',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
              const Spacer(),
              if (uid != null && uid != debate.userId) ...[
                IconButton(
                  icon: const Icon(Icons.flag_outlined,
                      size: 18, color: AppTheme.textSecondary),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ReportContentDialog(
                        targetType: 'debate',
                        targetId: debate.id,
                        targetTitle: debate.titulo,
                        targetAuthor: debate.userName,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.block_outlined,
                      size: 18, color: AppTheme.textSecondary),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Bloquear usuario'),
                        content: Text(
                            '¿Seguro que quieres bloquear a ${debate.userName}? No podrás ver su contenido ni interactuar con él.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Bloquear'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(firestoreServiceProvider)
                          .bloquearUsuario(uid!, debate.userId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario bloqueado')),
                        );
                      }
                    }
                  },
                ),
              ],
              if (uid == debate.userId && !debate.cerrado)
                TextButton(
                  onPressed: () {
                    ref.read(firestoreServiceProvider).cerrarDebate(debate.id);
                  },
                  child: const Text('Cerrar debate',
                      style: TextStyle(fontSize: 12)),
                ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicProfileScreen(
                          userId: debate.userId, fallbackName: debate.userName),
                    ),
                  );
                },
                child: Text(debate.userName,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          if (debate.libroNombre.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlueLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(debate.libroNombre,
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.primaryBlue)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReplyTile extends ConsumerWidget {
  final DebateReply reply;
  final String? uid;

  const _ReplyTile({required this.reply, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasVoted = reply.hasVoted(uid ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              ref.read(firestoreServiceProvider).toggleReplyVote(
                  reply.debateId, reply.id, uid ?? '', hasVoted);
            },
            child: Container(
              width: 32,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: hasVoted
                    ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Icon(Icons.arrow_drop_up,
                      color: hasVoted
                          ? AppTheme.primaryBlue
                          : AppTheme.textSecondary,
                      size: 16),
                  Text('${reply.upvotes}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasVoted
                              ? AppTheme.primaryBlue
                              : AppTheme.textPrimary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                                userId: reply.userId,
                                fallbackName: reply.userName),
                          ),
                        );
                      },
                      child: Text(reply.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppTheme.primaryBlue)),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('d MMM HH:mm').format(reply.fecha),
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                    if (uid != null && uid != reply.userId) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.flag_outlined,
                            size: 16, color: AppTheme.textSecondary),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => ReportContentDialog(
                              targetType: 'debate',
                              targetId: reply.id,
                              targetTitle: reply.texto.length > 50
                                  ? '${reply.texto.substring(0, 50)}...'
                                  : reply.texto,
                              targetAuthor: reply.userName,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.block_outlined,
                            size: 16, color: AppTheme.textSecondary),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Bloquear usuario'),
                              content: Text(
                                  '¿Seguro que quieres bloquear a ${reply.userName}? No podrás ver su contenido ni interactuar con él.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Bloquear'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(firestoreServiceProvider)
                                .bloquearUsuario(uid!, reply.userId);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Usuario bloqueado')),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(reply.texto,
                    style: const TextStyle(fontSize: 14, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
