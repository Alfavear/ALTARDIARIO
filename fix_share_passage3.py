content = open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8').read()

# The exact old share method
old_share = """  void _sharePassage() {
    if (_passages.isEmpty) return;
    final buffer = StringBuffer();
    for (final p in _passages) {
      buffer.writeln(p.reference);
      for (final v in p.verses) {
        buffer.writeln('${v.verse}: ${v.text}');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto copiado al portapapeles')),
    );
  }"""

new_share = """  final GlobalKey _shareKey = GlobalKey();

  Future<void> _sharePassage() async {
    if (_passages.isEmpty) return;

    // Build the content widget to capture
    final contentWidget = RepaintBoundary(
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
                      'Tu h\u00e1bito diario con Dios',
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
    );

    // Render to image
    try {
      final boundary = _shareKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file
      final tempDir = await getTemporaryDirectory();
      final fileName = 'altar_diario_\${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('\${tempDir.path}/\$fileName');
      await file.writeAsBytes(pngBytes);

      // Share using share_plus
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Lee este pasaje en AltarDiario \uD83D\uDCD6',
        subject: 'Vers\u00edculo del d\u00eda - AltarDiario',
      );
    } catch (e) {
      // Fallback to clipboard copy
      final buffer = StringBuffer();
      for (final p in _passages) {
        buffer.writeln(p.reference);
        for (final v in p.verses) {
          buffer.writeln('\${v.verse}: \${v.text}');
        }
      }
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Texto copiado al portapapeles')),
        );
      }
    }
  }

  String _getFullReference() {
    if (_passages.isEmpty) return '';
    return _passages.map((p) => p.reference).join('; ');
  }

  List<Widget> _buildVerseWidgets() {
    final widgets = <Widget>[];
    for (final p in _passages) {
      for (final v in p.verses) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '\${v.verse} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  TextSpan(text: v.text),
                ],
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }"""

if old_share in content:
    content = content.replace(old_share, new_share, 1)
    print('Share method updated')
else:
    print('Old share method not found')

# Also need to add imports for the new dependencies
imports_old = """import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';"""

imports_new = """import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';"""

if imports_old in content:
    content = content.replace(imports_old, imports_new, 1)
    print('Imports updated')
else:
    print('Imports not found or already updated')

# Write with proper encoding handling
with open('lib/presentation/screens/bible_reader_screen.dart', 'wb') as f:
    f.write(content.encode('utf-8'))
print('Done')