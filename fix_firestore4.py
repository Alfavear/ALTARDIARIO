content = open('lib/data/services/firestore_service.dart', 'r', encoding='utf-8').read()

# Remove duplicate section from index 11081 to 11978 (the "Reacciones" marker)
duplicate_start = 11081
duplicate_end = 11978

content = content[:duplicate_start] + content[duplicate_end:]

print(f'Removed duplicate from {duplicate_start} to {duplicate_end}')

with open('lib/data/services/firestore_service.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done')