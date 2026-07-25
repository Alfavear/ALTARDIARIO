---
name: flutter-test
description: Use when the user asks to write tests, fix tests, or run tests in the Flutter project. Covers unit tests and widget tests following project conventions.
---

# flutter-test

When writing tests in AltarDiario:

## Unit tests (models/services)
- Go in `test/models/` or `test/services/`
- Use `test()` for unit tests
- Mock SharedPreferences: `SharedPreferences.setMockInitialValues({})` in `setUp()`
- No mockito/mocktail — use real implementations or `SharedPreferences` mock

## Widget tests (screens)
- Go in `test/screens/`
- Use `testWidgets()` for widget tests
- Wrap in: `ProviderScope(overrides: [provider.overrideWithValue(...)], child: MaterialApp(...))`

## Fixtures
- Use inline maps/objects in test files (no fixture files needed)
- Use `final baseMap = { ... }` pattern for reusable test data

## Running tests
- `flutter test` — all tests
- `flutter test test/path/to/file.dart` — single file
- `flutter test --reporter expanded` — verbose output for debugging
