import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/bible_models.dart';
import '../../data/services/bible_service.dart';
import '../providers/app_providers.dart';
import 'bible_versions_screen.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
  final String pasajes;
  final String fechaClave;

  const BibleReaderScreen({
    super.key,
    required this.pasajes,
    required this.fechaClave,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final BibleService _bibleService = BibleService();
  BibleVersion _selectedVersion = BibleService.availableVersions.first;
  List<BibleVersion> _versions = BibleService.availableVersions;
  bool _isLoading = true;
  List<BiblePassage> _passages = [];
  List<BibleHighlight> _highlights = [];
  List<BibleNote> _notes = [];
  double _fontSize = 18.0;
  String? _errorMessage;

  static const Map<String, Color> _highlightColors = {
    '#FFF59D': Color(0xFFFFF59D),
    '#A5D6A7': Color(0xFFA5D6A7),
    '#90CAF9': Color(0xFF90CAF9),
    '#F8BBD0': Color(0xFFF8BBD0),
  };

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _loadVersions() async {
    final versions = await _bibleService.getAllAvailableVersions();
    if (!mounted) return;
    setState(() {
      _versions = versions;
      final exists = versions.any((v) => v.id == _selectedVersion.id);
      if (!exists) {
        _selectedVersion = versions.first;
      }
    });
  }

  Future<void> _loadText() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _loadVersions();

    try {
      final userId = ref.read(effectiveUserUidProvider);
      final passages = await _bibleService.getPassageText(
        widget.pasajes,
        version: _selectedVersion.id,
      );
      await _pullRemoteAnnotations(passages, userId);
      final highlights = await _bibleService.getHighlightsForPassages(
        passages,
        userId: userId,
      );
      final notes = await _bibleService.getNotesForPassages(
        passages,
        userId: userId,
      );

      if (!mounted) return;
      setState(() {
        _passages = passages;
        _highlights = highlights;
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar la Biblia offline.';
      });
    }
  }

  Future<void> _pullRemoteAnnotations(
    List<BiblePassage> passages,
    String? userId,
  ) async {
    if (userId == null) return;

    final anchors = _bibleService.getChapterAnchors(passages);
    if (anchors.isEmpty) return;

    try {
      final firestore = ref.read(firestoreServiceProvider);
      final remoteHighlights =
          await firestore.getBibleHighlightsForAnchors(userId, anchors);
      final remoteNotes = await firestore.getBibleNotesForAnchors(
        userId,
        anchors,
      );
      await _bibleService.upsertSyncedHighlights(remoteHighlights);
      await _bibleService.upsertSyncedNotes(remoteNotes);
    } catch (_) {
      // Offline reading should keep working even when cloud sync is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageService = ref.watch(storageProvider);
    final isCompleted = storageService.isDiaCompletado(widget.fechaClave);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        title: Text(
          widget.pasajes,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Tamaño de texto',
            icon: const Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                _fontSize = _fontSize >= 24 ? 16 : _fontSize + 2;
              });
            },
          ),
          PopupMenuButton<BibleVersion>(
            tooltip: 'Versión bíblica',
            icon: const Icon(Icons.translate),
            onSelected: (version) {
              if (version.id == '_manage_') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BibleVersionsScreen(),
                  ),
                );
                return;
              }
              setState(() => _selectedVersion = version);
              _loadText();
            },
            itemBuilder: (context) => [
              ..._versions.map((v) {
                return PopupMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      Icon(
                        v.id == _selectedVersion.id
                            ? Icons.offline_pin
                            : Icons.check_circle_outline,
                        size: 18,
                        color: v.id == _selectedVersion.id
                            ? AppTheme.primaryBlue
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(v.name)),
                    ],
                  ),
                );
              }),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: BibleVersion(
                  id: '_manage_',
                  name: 'Gestionar versiones...',
                  lang: '',
                ),
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Gestionar versiones...',
                        style: TextStyle(color: AppTheme.primaryBlue)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(isCompleted),
    );
  }

  Widget _buildBody(bool isCompleted) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.storage, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadText,
                child: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _buildOfflineBanner(),
              const SizedBox(height: 16),
              ..._passages.map(_buildPassage),
              if (!isCompleted) _buildCompleteButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.completedGreenLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: const Row(
        children: [
          Icon(Icons.offline_pin, color: AppTheme.completedGreen, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Biblia offline activa. Subrayados y notas se guardan localmente.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassage(BiblePassage passage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            passage.reference,
            style: const TextStyle(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          if (!passage.hasText)
            _buildUnavailablePassage(passage)
          else
            ...passage.verses.map(_buildVerseTile),
        ],
      ),
    );
  }

  Widget _buildUnavailablePassage(BiblePassage passage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.pendingGray,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        passage.message ?? 'Pasaje no disponible.',
        style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
      ),
    );
  }

  Widget _buildVerseTile(BibleVerse verse) {
    final highlight = _highlightForVerse(verse);
    final note = _noteForVerse(verse);
    final highlightColor = highlight == null
        ? Colors.transparent
        : _colorFromHex(highlight.colorHex).withValues(alpha: 0.45);

    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      onTap: () => _showVerseActions(verse, highlight, note),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: highlightColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${verse.verse}',
                style: TextStyle(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: _fontSize * 0.72,
                ),
              ),
            ),
            Expanded(
              child: Text(
                verse.text,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: _fontSize,
                  height: 1.55,
                ),
              ),
            ),
            if (note != null)
              const Padding(
                padding: EdgeInsets.only(left: 8, top: 3),
                child: Icon(Icons.sticky_note_2_outlined,
                    size: 18, color: AppTheme.accentGold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    final storageService = ref.watch(storageProvider);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ElevatedButton.icon(
          onPressed: () async {
            await storageService.markDateAsCompleted(widget.fechaClave);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lectura completada')),
              );
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('FINALIZAR LECTURA'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.completedGreen,
            minimumSize: const Size(240, 50),
          ),
        ),
      ),
    );
  }

  Future<void> _showVerseActions(
    BibleVerse verse,
    BibleHighlight? highlight,
    BibleNote? note,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse.reference,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  verse.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Subrayar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ..._highlightColors.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            Navigator.pop(context);
                            await _saveHighlight(verse, entry.key);
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: entry.value,
                          ),
                        ),
                      );
                    }),
                    if (highlight != null)
                      TextButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _deleteHighlight(highlight.id);
                        },
                        icon: const Icon(Icons.format_color_reset),
                        label: const Text('Quitar'),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.sticky_note_2_outlined),
                  title:
                      Text(note == null ? 'Añadir nota' : 'Ver o cambiar nota'),
                  subtitle: note == null
                      ? null
                      : Text(note.body,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    Navigator.pop(context);
                    _showNoteEditor(verse, note);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showNoteEditor(
      BibleVerse verse, BibleNote? existingNote) async {
    final controller = TextEditingController(text: existingNote?.body ?? '');
    final body = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Nota en ${verse.reference}'),
          content: TextField(
            controller: controller,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Escribe tu nota devocional...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (body == null || body.trim().isEmpty) return;
    await _saveNote(verse, body);
  }

  Future<void> _saveHighlight(BibleVerse verse, String colorHex) async {
    final userId = ref.read(effectiveUserUidProvider);
    final highlight = await _bibleService.saveHighlight(
      verse: verse,
      colorHex: colorHex,
      userId: userId,
    );
    if (userId != null) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .syncBibleHighlight(userId, highlight);
        await _bibleService.markHighlightSynced(highlight.id);
      } catch (_) {}
    }
    await _loadText();
  }

  Future<void> _deleteHighlight(String highlightId) async {
    final userId = ref.read(effectiveUserUidProvider);
    await _bibleService.deleteHighlight(highlightId);
    if (userId != null) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .deleteBibleHighlight(userId, highlightId);
      } catch (_) {}
    }
    await _loadText();
  }

  Future<void> _saveNote(
    BibleVerse verse,
    String body, {
    BibleNote? existingNote,
  }) async {
    final userId = ref.read(effectiveUserUidProvider);
    final note = await _bibleService.saveNote(
      verse: verse,
      body: body,
      userId: userId,
      existingNote: existingNote,
    );
    if (userId != null) {
      try {
        await ref.read(firestoreServiceProvider).syncBibleNote(userId, note);
        await _bibleService.markNoteSynced(note.id);
      } catch (_) {}
    }
    await _loadText();
  }

  BibleHighlight? _highlightForVerse(BibleVerse verse) {
    for (final highlight in _highlights) {
      if (highlight.contains(verse)) return highlight;
    }
    return null;
  }

  BibleNote? _noteForVerse(BibleVerse verse) {
    for (final note in _notes) {
      if (note.version == verse.version &&
          note.bookId == verse.bookId &&
          note.chapter == verse.chapter &&
          note.verse == verse.verse) {
        return note;
      }
    }
    return null;
  }

  Color _colorFromHex(String hex) {
    final normalized = hex.replaceFirst('#', '');
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
