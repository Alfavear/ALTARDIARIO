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
  final bool readOnly;

  const BibleReaderScreen({
    super.key,
    required this.pasajes,
    required this.fechaClave,
    this.readOnly = false,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  final BibleService _bibleService = BibleService();
  BibleVersion _selectedVersion = BibleService.availableVersions.first;
  List<BibleVersion> _versions = BibleService.availableVersions;
  bool _isLoading = true;
  bool _isDownloading = false;
  int _downloadProgress = 0;
  int _downloadTotal = 0;
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

  int? _selectedBookId;
  int _selectedChapter = 1;
  int _maxChapters = 1;

  @override
  void initState() {
    super.initState();
    _autoDownloadDefault();
  }

  void _parseInitialPassage() {
    final match = RegExp(r'^(.+?)\s+(\d+)$', caseSensitive: false)
        .firstMatch(widget.pasajes);
    if (match != null) {
      final book = match.group(1)!;
      final chapter = int.parse(match.group(2)!);
      final id = _bibleService.getBookIdFromName(book);
      if (id != -1) {
        _selectedBookId = id;
        _selectedChapter = chapter;
        _loadChapterCount();
      }
    }
  }

  void _loadChapterCount() {
    if (_selectedBookId == null) return;
    final count = _bibleService.getMaxChapter(_selectedBookId!);
    setState(() => _maxChapters = count > 0 ? count : 1);
  }

  Future<void> _loadBookChapter(String name, int bookId) async {
    _selectedBookId = bookId;
    _selectedChapter = 1;
    _loadChapterCount();
    await _navigateToPassage('$name 1');
  }

  Future<void> _navigateToPassage(String query) async {
    setState(() => _isLoading = true);

    final passages = await _bibleService.getPassageText(
      query,
      version: _selectedVersion.id,
    );

    if (!mounted) return;

    final userId = ref.read(effectiveUserUidProvider);
    try {
      await _pullRemoteAnnotations(passages, userId);
    } catch (_) {}

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
  }

  Future<void> _goToChapter(int chapter) async {
    if (_selectedBookId == null) return;
    setState(() => _selectedChapter = chapter);
    final name = _bibleService.getBookNameFromId(_selectedBookId!);
    await _navigateToPassage('$name $chapter');
  }

  void _showBookSelector() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final sorted = _bibleService.getBookNames();
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollCtrl) => Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text('Seleccionar libro',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  itemCount: sorted.length,
                  itemBuilder: (_, i) {
                    final name = sorted[i];
                    final id = _bibleService.getBookIdFromName(name);
                    final isSelected = id == _selectedBookId;
                    return ListTile(
                      title: Text(name,
                          style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppTheme.primaryBlue
                                  : null)),
                      trailing: isSelected
                          ? const Icon(Icons.check,
                              color: AppTheme.primaryBlue)
                          : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _loadBookChapter(name, id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _autoDownloadDefault() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });
    await _bibleService.ensureDefaultDownloaded(
      onProgress: (current, total) {
        if (mounted) {
          setState(() {
            _downloadProgress = current;
            _downloadTotal = total;
          });
        }
      },
    );
    if (mounted) {
      setState(() => _isDownloading = false);
      _parseInitialPassage();
      _loadText();
    }
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

    try {
      await _loadVersions();

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
        title: GestureDetector(
          onTap: widget.readOnly ? _showBookSelector : null,
          child: Row(
            children: [
              if (widget.readOnly)
                const Icon(Icons.menu_book_rounded,
                    size: 20, color: AppTheme.primaryBlue),
              if (widget.readOnly) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.readOnly && _selectedBookId != null
                      ? '${_bibleService.getBookNameFromId(_selectedBookId!)} $_selectedChapter'
                      : widget.pasajes,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.readOnly)
                const Icon(Icons.arrow_drop_down,
                    color: AppTheme.textSecondary),
            ],
          ),
        ),
        actions: [
          if (widget.readOnly)
            IconButton(
              tooltip: 'Seleccionar libro',
              icon: const Icon(Icons.library_books_outlined),
              onPressed: _showBookSelector,
            ),
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
    if (_isDownloading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryBlue),
              const SizedBox(height: 24),
              const Text(
                'Descargando Reina-Valera 1960…',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_downloadTotal > 0)
                Text(
                  '$_downloadProgress de $_downloadTotal versículos',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
            ],
          ),
        ),
      );
    }

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
              if (!widget.readOnly && !isCompleted) _buildCompleteButton(),
            ],
          ),
        ),
        if (widget.readOnly && _selectedBookId != null)
          _buildChapterNav(),
      ],
    );
  }

  Widget _buildChapterNav() {
    final bookName = _bibleService.getBookNameFromId(_selectedBookId!);
    final verseRange = _getVerseRange();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.pendingGray)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                label: 'Ant.',
                onTap: _selectedChapter > 1
                    ? () => _goToChapter(_selectedChapter - 1)
                    : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CarouselSegment(
                      icon: Icons.menu_book,
                      label: bookName.length > 12
                          ? '${bookName.substring(0, 10)}…'
                          : bookName,
                      onTap: _showBookSelector,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.chevron_right,
                          size: 14, color: AppTheme.textSecondary),
                    ),
                    _CarouselSegment(
                      icon: Icons.collections_bookmark,
                      label: '$_selectedChapter',
                      badge: 'Cap.',
                      onTap: _showChapterPicker,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.chevron_right,
                          size: 14, color: AppTheme.textSecondary),
                    ),
                    _CarouselSegment(
                      icon: Icons.format_list_numbered,
                      label: verseRange,
                      badge: 'Vers.',
                      onTap: _showVersePicker,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _NavButton(
                icon: Icons.chevron_right,
                label: 'Sig.',
                onTap: _selectedChapter < _maxChapters
                    ? () => _goToChapter(_selectedChapter + 1)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getVerseRange() {
    if (_passages.isEmpty) return '1-?';
    final all = <int>[];
    for (final p in _passages) {
      for (final v in p.verses) {
        all.add(v.verse);
      }
    }
    if (all.isEmpty) return '?';
    all.sort();
    final min = all.first;
    final max = all.last;
    return min == max ? '$min' : '$min-$max';
  }

  void _showVersePicker() {
    if (_passages.isEmpty) return;
    final all = <int>[];
    final verseMap = <int, String>{};
    for (final p in _passages) {
      for (final v in p.verses) {
        all.add(v.verse);
        verseMap[v.verse] = v.text;
      }
    }
    all.sort();

    final maxVer = all.isNotEmpty ? all.last : 50;
    final rows = List.generate(maxVer, (i) => i + 1);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Seleccionar versículo',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 300,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  childAspectRatio: 1.2,
                ),
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final v = rows[i];
                  final exists = verseMap.containsKey(v);
                  final inRange = v >= (all.isNotEmpty ? all.first : 0) &&
                      v <= (all.isNotEmpty ? all.last : 0);
                  return Material(
                    color: exists
                        ? inRange
                            ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                            : AppTheme.pendingGray
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: exists
                          ? () {
                              Navigator.pop(ctx);
                              _scrollToVerse(v);
                            }
                          : null,
                      child: Center(
                        child: Text(
                          '$v',
                          style: TextStyle(
                            fontWeight: (exists && inRange)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: exists
                                ? inRange
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textSecondary
                                : AppTheme.pendingGrayDark,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _scrollToVerse(int verse) {
    final list = context.findRenderObject();
    if (list == null) return;
  }

  void _showChapterPicker() {
    if (_selectedBookId == null) return;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final rows = <int>[];
        for (var i = 1; i <= _maxChapters; i++) {
          rows.add(i);
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Seleccionar capítulo',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 300,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: rows.length,
                itemBuilder: (_, i) {
                  final ch = rows[i];
                  final isCurrent = ch == _selectedChapter;
                  return Material(
                    color: isCurrent
                        ? AppTheme.primaryBlue
                        : AppTheme.pendingGray,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Navigator.pop(ctx);
                        _goToChapter(ch);
                      },
                      child: Center(
                        child: Text('$ch',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isCurrent ? Colors.white : null,
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap != null ? AppTheme.primaryBlue.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: onTap != null ? AppTheme.primaryBlue : AppTheme.pendingGrayDark),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: onTap != null ? AppTheme.primaryBlue : AppTheme.pendingGrayDark,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarouselSegment extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final VoidCallback? onTap;

  const _CarouselSegment({
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppTheme.primaryBlue),
              const SizedBox(height: 2),
              if (badge != null)
                Text(badge!,
                    style: const TextStyle(
                        fontSize: 8,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
