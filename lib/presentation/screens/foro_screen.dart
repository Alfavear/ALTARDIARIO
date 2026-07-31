import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/debate.dart';
import '../../data/services/bible_service.dart';
import '../providers/app_providers.dart';
import 'crear_debate_screen.dart';
import 'debate_detail_screen.dart';

class ForoScreen extends ConsumerStatefulWidget {
  const ForoScreen({super.key});

  @override
  ConsumerState<ForoScreen> createState() => _ForoScreenState();
}

class _ForoScreenState extends ConsumerState<ForoScreen> {
  String? _selectedLibro;
  final _searchController = TextEditingController();
  final _bibleService = BibleService();

  List<String> get _libros => _bibleService.getBookNames();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final debatesAsync = ref.watch(debatesStreamProvider(_selectedLibro));

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
  title: const Text('Foro Bíblico',
      style: TextStyle(fontWeight: FontWeight.bold)),
),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: debatesAsync.when(
              data: (debates) {
                var filtered = debates;
                final query = _searchController.text.trim().toLowerCase();
                if (query.isNotEmpty) {
                  filtered = filtered
                      .where((d) =>
                          d.titulo.toLowerCase().contains(query) ||
                          d.contenido.toLowerCase().contains(query))
                      .toList();
                }
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(debatesStreamProvider(_selectedLibro).future),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _DebateCard(debate: filtered[i]),
                  ),
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
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
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const CrearDebateScreen()),
          );
        },
        child: const Icon(Icons.add_comment_rounded,
            color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildFilters() {
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
                      hintText: 'Buscar debates...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12),
                    ),
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Todos',
                  selected: _selectedLibro == null,
                  onTap: () => setState(() => _selectedLibro = null),
                ),
                const SizedBox(width: 6),
                ..._libros.map((libro) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: _FilterChip(
                        label: libro,
                        selected: _selectedLibro == libro,
                        onTap: () =>
                            setState(() => _selectedLibro = libro),
                      ),
                    )),
              ],
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
                color: AppTheme.primaryBlueLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum,
                  size: 40, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aún no hay debates',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Sé el primero en iniciar un debate bíblico!',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primaryBlue
                : AppTheme.pendingGrayDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DebateCard extends ConsumerWidget {
  final Debate debate;
  const _DebateCard({required this.debate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(effectiveUserUidProvider);
    final hasVoted = debate.hasVoted(uid ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  DebateDetailScreen(debateId: debate.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    ref
                        .read(firestoreServiceProvider)
                        .toggleDebateVote(
                            debate.id, uid ?? '', hasVoted);
                  },
                  child: Container(
                    width: 40,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: hasVoted
                          ? AppTheme.primaryBlue
                              .withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          hasVoted
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_up,
                          color: hasVoted
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                        Text(
                          '${debate.upvotes}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hasVoted
                                ? AppTheme.primaryBlue
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(debate.titulo,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      if (debate.contenido.isNotEmpty)
                        Text(debate.contenido,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.3)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (debate.libroNombre.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlueLight
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(debate.libroNombre,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color:
                                          AppTheme.primaryBlue)),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Icon(Icons.chat_bubble_outline,
                              size: 13,
                              color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Text('${debate.replyCount}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary)),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('d MMM').format(debate.fecha),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
