with open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_method = """List<Widget> _buildVerseWidgets() {
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
                    text: '${v.verse} ',
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
  }

  @override
  void initState() {"""

new_method = """@override
  void initState() {"""

content = open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8').read()

if old in content:
    content = content.replace(old, new, 1)
    with open('lib/presentation/screens/bible_reader_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Method removed')
else:
    print('Old method not found')