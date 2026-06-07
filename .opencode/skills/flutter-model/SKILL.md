---
name: flutter-model
description: Use when the user asks to create a new data model for the Flutter app. Creates the model file and its corresponding test file.
---

# flutter-model

When creating a new model in AltarDiario:

1. Create the model file in `lib/data/models/` as `snake_case_name.dart`
2. Use Spanish naming for domain concepts, English for technical concepts
3. All fields must be `final`, prefer `const` constructors
4. Include `Map<String, dynamic> toMap()` and `factory ModelName.fromMap(Map)`
5. If the model goes to Firestore, add `factory ModelName.fromFirestore(DocumentSnapshot)` and use `??` for null safety
6. Never use `as` casting — use `??` with defaults
7. NO `freezed` or code generation

Test file goes in `test/models/snake_case_name_test.dart`.
Test pattern: `group('ModelName')` with `test('descripción en español', ...)`.
Cover: fromMap happy path, null defaults, toMap round-trip, copyWith if applicable.
