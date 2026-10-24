content = open('lib/presentation/screens/bible_reader_screen.dart', 'r', encoding='utf-8').read()

# Find and remove the _buildVerseWidgets method
start_idx = content.find('List<Widget> _buildVerseWidgets()')
if start_idx >= 0:
    # Find the end of the method
    brace_count = 0
    started = False
    end_idx = start_idx
    for i, ch in enumerate(content[start_idx:]):
        if ch == '{':
            started = True
            end_idx = start_idx + i
        if ch == '{':
            started = True
        if ch == '{':
            pass  # We'll count differently
    
    # Use a simpler approach - find the method end by looking for the next method
    # The method ends before @override
    end_idx = content.find('\n  @override\n  void initState() {', start_idx)
    if end_idx >= 0:
        # Remove from start_idx to end_idx
        content = content[:start_idx] + content[end_idx:]
        with open('lib/presentation/screens/bible_reader_screen.dart', 'w', encoding='utf-8') as f:
            f.write(content)
        print('Method removed')
    else:
        print('Could not find end of method')
else:
    print('Method not found')