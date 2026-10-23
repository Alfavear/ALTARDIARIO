import 'package:altar_diario/features/biblioteca/presentation/hoja_exportar_biblioteca.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('avisa de que nada sale del dispositivo sin pedirlo',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HojaExportarBiblioteca(
            texto: '# Mi biblioteca\n\nHola',
            onCopiar: () {},
          ),
        ),
      ),
    );

    expect(find.textContaining('No se envía nada a otros usuarios'),
        findsOneWidget);
    expect(find.textContaining('# Mi biblioteca'), findsOneWidget);
  });

  testWidgets('solo copia cuando el usuario pulsa Copiar', (tester) async {
    var copiado = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HojaExportarBiblioteca(
            texto: 'texto',
            onCopiar: () => copiado++,
          ),
        ),
      ),
    );

    expect(copiado, 0, reason: 'abrir la hoja no exporta nada');

    await tester.tap(find.text('Copiar'));
    await tester.pump();

    expect(copiado, 1);
  });
}
