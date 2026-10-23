with open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix imports
content = content.replace(
    """import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dar';""",
    """import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';""")

# 2. Add _shareKey field
content = content.replace(
    """  BibleVersion _selectedVersion = BibleService.availableVersions.first;
  List<BibleVersion> _versions = BibleService.availableVersions;""",
    """BibleVersion _selectedVersion = BibleService.availableVersions.first;
  List<BibleVersion> _versions = BibleService.availableVersions;
  final GlobalKey _shareKey = GlobalKey();""")

# 3. Replace _sharePassage method
old_share = """  void _sharePassage() {
    if (_passages.isEmpty) return;
    final buffer = StringBuffer();
    for (final p in _passages) {
      buffer.writeln(p.reference);
      for (final v in p.verses) {
        buffer.writeln('\${v.verse}: \${v.text}');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Texto copiado al portapapeles')),
    );
  }"""

new_share = """  Future<void> _sharePassage() async {
    if (_passages.isEmpty) return;

    // Build the passage text
    final buffer = StringBuffer();
    buffer.writeln('AltarDiario - Tu hábito diario con Dios');
    buffer.writeln('');
    buffer.writeln(_getFullReference());
    buffer.writeln('');
    for (final p in _passages) {
      for (final v in p.verses) {
        buffer.writeln('\${v.verse}: \${v.text}');
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

content = content.replace(old_share, new_share, 1)

# Write the modified content
with open('lib/presentation/screens/bible_reader_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Changes applied successfully')