import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/note.dart';
import '../providers/app_providers.dart';
import 'note_editor_screen.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                color: AppTheme.primaryBlue, size: 22),
            const SizedBox(width: 8),
            Text('AltarDiario',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: AppTheme.primaryBlue, fontSize: 20)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscar notas — próximamente')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppTheme.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notificaciones — próximamente')),
              );
            },
          ),
        ],
      ),
      body: _NotesBody(),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: AppTheme.primaryBlue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const NoteEditorScreen(),
            ),
          );
          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nota guardada')),
            );
          }
        },
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _NotesBody extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NotesBody> createState() => _NotesBodyState();
}

class _NotesBodyState extends ConsumerState<_NotesBody> {
  String _selectedFilter = 'Todas';
  final List<String> _filters = [
    'Todas',
    'Gratitud',
    'Intercesión',
    'Aprendizaje',
    'Biblia',
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Note>>(
      future: ref.read(storageProvider).getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data ?? [];
        final filtered = _selectedFilter == 'Todas'
            ? notes
            : notes
                .where((n) =>
                    n.title.toLowerCase().contains(_selectedFilter.toLowerCase()))
                .toList();
        final sorted = [...filtered]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit_note,
                          size: 18, color: AppTheme.primaryBlueLight),
                      const SizedBox(width: 6),
                      Text(
                        'MIS NOTAS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlueLight,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reflexiones y momentos compartidos con Dios.',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 15),
                  ),
                ],
              ),
            ),
            _buildFilterChips(),
            Expanded(
              child: notes.isEmpty ? _buildEmptyState() : _buildNotesGrid(sorted),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = _filters[i];
          final selected = f == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                f,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
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
            Icon(Icons.lightbulb_outline,
                size: 48, color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              '¿Qué te habló Dios hoy?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca + para crear tu primera nota.\nApuntes, prédicas, ideas… todo guardado aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    if (notes.isEmpty) return _buildEmptyState();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: notes.length,
      itemBuilder: (context, i) {
        final note = notes[i];
        return _NoteCard(note: note);
      },
    );
  }
}

class _NoteCard extends ConsumerWidget {
  final Note note;
  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
        border: Border.all(color: AppTheme.pendingGrayDark.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CategoryTag(label: _guessCategory(note.title)),
              Text(
                DateFormat('dd MMM yyyy – HH:mm').format(note.updatedAt),
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note.title.isEmpty ? 'Sin título' : note.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          if (note.content.isNotEmpty)
            Text(
              note.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_outline,
                      size: 18, color: AppTheme.textSecondary),
                  const SizedBox(width: 12),
                  Icon(Icons.share_outlined,
                      size: 18, color: AppTheme.textSecondary),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NoteEditorScreen(existingNote: note),
                    ),
                  );
                  if (result == true && context.mounted) {
                    (context as Element).markNeedsBuild();
                  }
                },
                child: const Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _guessCategory(String title) {
    final t = title.toLowerCase();
    if (t.contains('gratitud') || t.contains('gracias') || t.contains('salmo')) {
      return 'Gratitud';
    }
    if (t.contains('orac') || t.contains('interces') || t.contains('familia')) {
      return 'Intercesión';
    }
    if (t.contains('aprend') || t.contains('lecc') || t.contains('roman')) {
      return 'Aprendizaje';
    }
    if (t.contains('biblia') || t.contains('pasaje') || t.contains('lectura') || t.contains('vers')) {
      return 'Biblia';
    }
    return 'Gratitud';
  }
}

class _CategoryTag extends StatelessWidget {
  final String label;
  const _CategoryTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final isIntercesion = label == 'Intercesión';
    final isAprendizaje = label == 'Aprendizaje';
    final isBiblia = label == 'Biblia';
    final bgColor = isIntercesion
        ? AppTheme.primaryBlue.withValues(alpha: 0.12)
        : isAprendizaje
            ? AppTheme.accentGoldLight.withValues(alpha: 0.3)
            : isBiblia
                ? AppTheme.completedGreenLight
                : AppTheme.completedGreenLight;
    final textColor = isIntercesion
        ? AppTheme.primaryBlue
        : isAprendizaje
            ? AppTheme.textPrimary
            : isBiblia
                ? AppTheme.completedGreen
                : AppTheme.completedGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
