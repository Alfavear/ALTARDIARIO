content = open('lib/data/services/firestore_service.dart', 'r', encoding='utf-8').read()

# Remove duplicate ocultarDebate and cerrarDebate
# The duplicate section starts with "/// Oculta un debate (moderación)." and ends before "// ─────────────────────────────────────────────────────────────────────────────"
# Find the second occurrence of "/// Oculta un debate (moderación)."
first_idx = content.find('/// Oculta un debate (moderación).')
second_idx = content.find('/// Oculta un debate (moderación).', content.find('/// Oculta un debate (moderación).') + 100)

if second_idx >= 0:
    # Find the end of the duplicate section (before "// ─────────────────────────────────────────────────────────────────────────────")
    end_idx = content.find('// ─────────────────────────────────────────────────────────────────────────────', second_idx)
    if end_idx >= 0:
        # Remove from second_idx to end_idx
        content = content[:second_idx] + content[end_idx:]
        print('Removed duplicate methods')
    else:
        print('Could not find end marker')
else:
    print('Could not find second occurrence')

with open('lib/data/services/firestore_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')