with open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_method = """Future<void> _sharePassage() async {
    if (_passages.isEmpty) return;

    // Build the content widget to capture
    RepaintBoundary(
      key: _shareKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AltarDiario branding
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AltarDiario',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      'Tu hábito diario con Dios',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Passage reference
            Text(
              _getFullReference(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            // Verses
            ..._buildVerseWidgets(),
            const SizedBox(height: 20),
            // Footer
            const Divider(),
            const Text(
              'Compartido desde AltarDiario',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    ),

    // Render to image
    try {
      final boundary =
          _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'altar_diario_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      // Share using share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Lee este pasaje en AltarDiario 📖',
        subject: 'Versículo del día - AltarDiario',
      );
    } catch (e) {
      // Fallback to clipboard copy
      final buffer = StringBuffer();
      for (final p in _passages) {
        buffer.writeln(p.reference);
        for (final v in p.verses) {
          buffer.writeln('${v.verse}: ${v.text}');
        }
      }
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Texto copiado al portapapeles')),
        );
      }
    }
  }"""

new_method = """Future<void> _sharePassage() async {
    if (_passages.isEmpty) return;

    // Build the passage text
    final buffer = StringBuffer();
    buffer.writeln('AltarDiario - Tu hábito diario con Dios');
    buffer.writeln('');
    buffer.writeln(_getFullReference());
    buffer.writeln('');
    for (final p in _passages) {
      for (final v in p.verses) {
        buffer.writeln('${v.verse}: ${v.text}');
      }
    }
    buffer.writeln('');
    buffer.writeln('Compartido desde AltarDiario 📖');

    final text = buffer.toString();

    try {
      await Share.share(
        text,
        subject: 'Versículo del día - AltarDiario',
      );
    } catch (e) {
      // Fallback to clipboard copy
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Texto copiado al portapapeles')),
        );
      }
    }
  }"""

content = open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8').read()

if old_method in content:
    content = content.replace(old_method, new_method, 1)
    with open('lib/presentation/screens/bible_reader_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Method replaced')
else:
    print('Old method not found')