---
name: flutter-screen
description: Use when the user asks to create a new screen or view in the Flutter app. Adds both the screen file and its test file following project conventions.
---

# flutter-screen

When creating a new screen in AltarDiario:

1. Create the screen file in `lib/presentation/screens/` as `snake_case_name_screen.dart`
2. Use `ConsumerWidget` by default, or `ConsumerStatefulWidget` if local mutable state is needed
3. Follow existing patterns (ref.watch for providers, .when() for AsyncValue)
4. Import providers from `../providers/app_providers.dart`
5. Register any new provider needed in `lib/presentation/providers/app_providers.dart`
6. Add to `MainNavigationView` if it's a new top-level tab

Test file goes in `test/screens/snake_case_name_screen_test.dart`.
Wrap widget in `ProviderScope(overrides: [...], child: MaterialApp(...))`.
