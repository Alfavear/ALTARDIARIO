import 'package:altar_diario/presentation/widgets/lectura_hoy_card.dart';
import 'package:altar_diario/presentation/widgets/lectura_hoy_estados.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> montar(
    WidgetTester tester,
    Widget tarjeta, {
    double escalaTexto = 1,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escalaTexto)),
        child: MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: tarjeta)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  LecturaHoyCard tarjeta({
    bool cargando = false,
    bool sinConexion = false,
    bool completado = false,
    String? versiculo = 'El Señor es mi pastor; nada me faltará.',
    String? referencia = 'Salmo 23:1',
    String? siguientePasaje,
    VoidCallback? onAbrir,
    VoidCallback? onMarcarCompletado,
    VoidCallback? onAbrirSiguiente,
  }) {
    return LecturaHoyCard(
      pasaje: 'Salmo 23',
      versiculo: versiculo,
      referencia: referencia,
      cargando: cargando,
      sinConexion: sinConexion,
      completado: completado,
      siguientePasaje: siguientePasaje,
      onAbrir: onAbrir ?? () {},
      onMarcarCompletado: onMarcarCompletado ?? () {},
      onAbrirSiguiente: onAbrirSiguiente,
    );
  }

  testWidgets('pendiente: muestra el pasaje y se abre con un toque',
      (tester) async {
    var abiertas = 0;
    await montar(tester, tarjeta(onAbrir: () => abiertas++));

    expect(find.text('Salmo 23'), findsOneWidget);
    expect(find.text('Salmo 23:1'), findsOneWidget);
    expect(find.text('Leer pasaje'), findsOneWidget);
    expect(find.text('¡Día completado!'), findsNothing);

    await tester.tap(find.text('Salmo 23'));
    await tester.pump();

    expect(abiertas, 1, reason: 'un solo toque abre la lectura pendiente');
  });

  testWidgets('cargando: muestra el skeleton y no el versículo',
      (tester) async {
    await montar(
      tester,
      tarjeta(cargando: true, versiculo: null, referencia: null),
    );

    expect(find.byType(LecturaSkeleton), findsOneWidget);
    expect(find.text('El Señor es mi pastor; nada me faltará.'), findsNothing);
  });

  testWidgets('sin conexión: avisa y mantiene el plan guardado',
      (tester) async {
    await montar(
      tester,
      tarjeta(sinConexion: true, versiculo: null, referencia: null),
    );

    expect(find.textContaining('Sin conexión'), findsOneWidget);
    expect(find.text('Leer pasaje'), findsOneWidget);
    expect(find.text('¡Día completado!'), findsNothing);
  });

  testWidgets('completado: celebración discreta y siguiente lectura',
      (tester) async {
    var marcadas = 0;
    var siguientes = 0;
    await montar(
      tester,
      tarjeta(
        completado: true,
        siguientePasaje: 'Génesis 1:11-20',
        onMarcarCompletado: () => marcadas++,
        onAbrirSiguiente: () => siguientes++,
      ),
    );

    expect(find.text('¡Día completado!'), findsOneWidget);
    expect(find.text('Siguiente: Génesis 1:11-20'), findsOneWidget);

    await tester.tap(find.text('Abrir'));
    await tester.pump();
    expect(siguientes, 1);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();
    expect(marcadas, 1);
    expect(siguientes, 1, reason: 'marcar no debe abrir la siguiente lectura');
  });

  testWidgets('escala de texto grande: no desborda', (tester) async {
    await montar(
      tester,
      tarjeta(completado: true, siguientePasaje: 'Génesis 1:11-20'),
      escalaTexto: 2.0,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('¡Día completado!'), findsOneWidget);
  });
}
