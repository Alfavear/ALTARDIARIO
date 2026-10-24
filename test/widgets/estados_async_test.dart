import 'package:altar_diario/presentation/widgets/estados/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AsyncStateBuilder', () {
    testWidgets('cargando muestra el indicador y no llama al builder',
        (tester) async {
      var construido = false;
      await tester.pumpWidget(_app(AsyncStateBuilder<int>(
        isLoading: true,
        error: null,
        items: null,
        onRetry: () {},
        builder: (_, __) {
          construido = true;
          return const SizedBox();
        },
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(construido, isFalse);
    });

    testWidgets('con error muestra el mensaje y Reintentar llama a onRetry',
        (tester) async {
      var reintentos = 0;
      await tester.pumpWidget(_app(AsyncStateBuilder<int>(
        isLoading: false,
        error: Exception('sin red'),
        items: null,
        onRetry: () => reintentos++,
        builder: (_, __) => const SizedBox(),
      )));

      expect(find.text('No pudimos cargar la información'), findsOneWidget);
      // El detalle técnico del error no se filtra al usuario.
      expect(find.textContaining('sin red'), findsNothing);

      await tester.tap(find.text('Reintentar'));
      expect(reintentos, 1);
    });

    testWidgets('lista vacía muestra el estado vacío con su acción',
        (tester) async {
      var acciones = 0;
      await tester.pumpWidget(_app(AsyncStateBuilder<int>(
        isLoading: false,
        error: null,
        items: const <int>[],
        onRetry: () {},
        builder: (_, __) => const SizedBox(),
        emptyTitle: 'Sin notas',
        emptyDescription: 'Escribe la primera.',
        emptyActionLabel: 'Crear nota',
        onEmptyAction: () => acciones++,
      )));

      expect(find.text('Sin notas'), findsOneWidget);
      await tester.tap(find.text('Crear nota'));
      expect(acciones, 1);
    });

    testWidgets('con datos delega en el builder', (tester) async {
      await tester.pumpWidget(_app(AsyncStateBuilder<int>(
        isLoading: false,
        error: null,
        items: const [1, 2, 3],
        onRetry: () {},
        builder: (_, data) => Text('total ${data.length}'),
      )));

      expect(find.text('total 3'), findsOneWidget);
    });

    testWidgets('el error tiene prioridad sobre los datos', (tester) async {
      await tester.pumpWidget(_app(AsyncStateBuilder<int>(
        isLoading: false,
        error: 'x',
        items: const [1],
        onRetry: () {},
        builder: (_, __) => const Text('datos'),
      )));

      expect(find.text('datos'), findsNothing);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  testWidgets('EmptyStateView sin acción no pinta botón', (tester) async {
    await tester.pumpWidget(_app(const EmptyStateView(
      icon: Icons.inbox_outlined,
      title: 'Vacío',
      description: 'Nada aquí.',
    )));

    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('ErrorStateView respeta retryLabel', (tester) async {
    await tester.pumpWidget(_app(ErrorStateView(
      message: 'Falló',
      retryLabel: 'Probar otra vez',
      onRetry: () {},
    )));

    expect(find.text('Probar otra vez'), findsOneWidget);
    expect(find.text('Reintentar'), findsNothing);
  });

  testWidgets('LoadingStateView muestra el mensaje opcional', (tester) async {
    await tester.pumpWidget(_app(const LoadingStateView(message: 'Cargando…')));

    expect(find.text('Cargando…'), findsOneWidget);
  });
}
