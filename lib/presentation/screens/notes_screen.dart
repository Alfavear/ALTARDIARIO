import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      appBar: AppBar(
        title: const Text('Mis Notas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
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
          ),
        ],
      ),
      body: _NotesList(),
    );
  }
}

class _NotesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Note>>(
      future: ref.read(storageProvider).getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.note_alt_outlined,
                      size: 64,
                      color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes notas aún',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        final sorted = [...notes]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: sorted.length,
          itemBuilder: (context, i) {
            final note = sorted[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  note.title.isEmpty ? 'Sin título' : note.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.content.isNotEmpty)
                      Text(note.content,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy – HH:mm').format(note.updatedAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleAction(context, ref, value, note),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                    const PopupMenuItem(value: 'copy', child: Text('Copiar')),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
                onTap: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NoteEditorScreen(existingNote: note),
                    ),
                  );
                  if (result == true && context.mounted) {
                    (context as Element).markNeedsBuild();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _handleAction(
      BuildContext context, WidgetRef ref, String action, Note note) {
    switch (action) {
      case 'edit':
        Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => NoteEditorScreen(existingNote: note),
          ),
        ).then((result) {
          if (result == true && context.mounted) {
            (context as Element).markNeedsBuild();
          }
        });
      case 'copy':
        Clipboard.setData(
            ClipboardData(text: '${note.title}\n\n${note.content}'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copiado al portapapeles')),
        );
      case 'delete':
        ref.read(storageProvider).deleteNote(note.id).then((_) {
          if (context.mounted) {
            (context as Element).markNeedsBuild();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nota eliminada')),
            );
          }
        });
    }
  }
}
