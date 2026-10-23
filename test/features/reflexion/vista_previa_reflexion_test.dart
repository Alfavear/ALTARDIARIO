import 'package:altar_diario/features/reflexion/presentation/vista_previa_reflexion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra el pasaje y el texto exactos que se publican',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VistaPreviaReflexion(
            pasaje: 'Salmo 23',
            texto: 'El Señor es mi pastor; nada me faltará.',
          ),
        ),
      ),
    );

    expect(find.text('Así se verá tu reflexión'), findsOneWidget);
    expect(find.text('Salmo 23'), findsOneWidget);
    expect(
        find.text('El Señor es mi pastor; nada me faltará.'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
    expect(find.text('Seguir editando'), findsOneWidget);
    expect(
      find.textContaining('visible para la comunidad'),
      findsOneWidget,
      reason: 'el usuario debe saber que la reflexión se hace pública',
    );
  });

  testWidgets('publicar devuelve true y seguir editando devuelve false',
      (tester) async {
    Future<bool?>? resultado;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                resultado = showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const VistaPreviaReflexion(
                    pasaje: 'Salmo 23',
                    texto: 'Texto de prueba',
                  ),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(await resultado, isFalse);

    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar'));
    await tester.pumpAndSettle();
    expect(await resultado, isTrue);
  });
}
