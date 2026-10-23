content = open('lib/data/services/firestore_service.dart', 'r', encoding='utf-8').read()

# Remove duplicate section from index 11081 to the "Reacciones" marker
duplicate_start = 11081
# Find the "Reacciones" marker
end_marker = '// ─────────────────────────────────────────────────────────────────────────────\n// Reacciones'
end_idx = content.find(end_marker, duplicate_start)

if end_idx >= 0:
    # Remove from duplicate_start to end_idx
    content = content[:duplicate_start] + content[end_idx:]
    print(f'Removed duplicate from {duplicate_start} to {end_idx}')
else:
    print('Could not find end marker')

with open('lib/data/services/firestore_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')