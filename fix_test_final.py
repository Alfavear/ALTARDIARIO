with open('test/services/firestore_service_test.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the exact pattern
old = """            'fecha': DateTime.utc(2026, 1, i + 1),\n          });"""

new = """            'fecha': DateTime.utc(2026, 1, i + 1),\n            'oculto': false,\n          });"""

if old in content:
    content = content.replace(old, new, 1)
    with open('test/services/firestore_service_test.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print('Done')
else:
    print('Not found')