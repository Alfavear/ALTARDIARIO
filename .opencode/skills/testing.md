# Skill: Testing (Flutter + Riverpod + Firebase)

## Convenciones del Proyecto
- **Framework**: `flutter_test` únicamente (NO mockito, NO mocktail)
- **Mocks**: Manuales o `SharedPreferences.setMockInitialValues({})`
- **Wrapper**: `ProviderScope(overrides: [...], child: MaterialApp(...))`

## Estructura de Tests
```
test/
  models/           # Unit tests: Model.fromMap, toMap, fromFirestore
  services/         # Unit tests: StorageService, AuthService (mock Firebase)
  screens/          # Widget tests: ConsumerWidget + ProviderScope overrides
  widget_test.dart  # Test de integración smoke
```

## Patrones de Test

### Modelos (Unit)
```dart
// test/models/reflexion_test.dart
group('Reflexion', () {
  test('fromFirestore parsea correctamente', () {
    final doc = _mockDoc('r1', {'userId': 'u1', 'texto': 'Hola', 'fecha': Timestamp.now()});
    final r = Reflexion.fromFirestore(doc);
    expect(r.id, 'r1');
    expect(r.userId, 'u1');
    expect(r.texto, 'Hola');
  });

  test('toMap incluye todos los campos', () {
    final r = Reflexion(id: 'r1', userId: 'u1', texto: 'Hola', fecha: DateTime.now());
    final map = r.toMap();
    expect(map['userId'], 'u1');
    expect(map['texto'], 'Hola');
  });
});
```

### Servicios (Unit) — Mock Firebase
```dart
// test/services/storage_service_test.dart
setUp(() {
  SharedPreferences.setMockInitialValues({
    'plan_start_date': '2026-01-01',
    'completed_dates': ['2026-01-01', '2026-01-02'],
    'focus_mode': true,
  });
});

test('getFocusMode retorna valor guardado', () async {
  final service = StorageService();
  expect(await service.getFocusMode(), true);
});
```

### Widgets (Widget Test)
```dart
// test/screens/home_screen_test.dart
testWidgets('HomeScreen muestra versículo del día', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        storageProvider.overrideWithValue(MockStorageService()),
        authStateProvider.overrideWithValue(const AsyncValue.data(null)),
        reflexionesStreamProvider.overrideWithValue(const AsyncValue.data([])),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.textContaining('Versículo del día'), findsOneWidget);
});
```

### Providers Override Comunes
```dart
final overrides = [
  storageProvider.overrideWithValue(mockStorage),
  authServiceProvider.overrideWithValue(mockAuth),
  firestoreServiceProvider.overrideWithValue(mockFirestore),
  authStateProvider.overrideWithValue(AsyncValue.data(mockUser)),
  reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
];
```

## Comandos
```bash
flutter test                              # Todos los tests
flutter test test/models/reflexion_test.dart  # Archivo específico
flutter test --coverage                   # Con coverage
```

## Reglas del Proyecto
- **SIEMPRE** test para modelos nuevos (`fromFirestore`, `toMap`, `fromMap`)
- **SIEMPRE** widget test para pantallas nuevas
- **NUNCA** mockito/mocktail — mocks manuales o `SharedPreferences.setMockInitialValues`
- Tests en español: `test('descripción en español', ...)`