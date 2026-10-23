import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/features/oracion/presentation/screens/oracion_screen.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness({required bool isGuest, List<PeticionOracion>? peticiones}) {
  return ProviderScope(
    overrides: [
      isGuestUserProvider.overrideWithValue(isGuest),
      if (peticiones != null)
        peticionesFiltradasProvider
            .overrideWith((ref) => Stream.value(peticiones)),
    ],
    child: const MaterialApp(home: OracionScreen()),
  );
}

void main() {
  testWidgets('invitado ve la pantalla restringida y no puede pedir oración',
      (tester) async {
    await tester.pumpWidget(_harness(isGuest: true));
    await tester.pump();

    expect(
        find.textContaining('Compañeros de Oración Reservado'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('sin peticiones muestra el estado vacío', (tester) async {
    await tester.pumpWidget(_harness(isGuest: false, peticiones: const []));
    await tester.pumpAndSettle();

    expect(find.text('No hay peticiones activas.'), findsOneWidget);
    expect(find.text('Pedir Oración'), findsOneWidget);
  });

  testWidgets('una petición muestra autor, motivo y contador de oración',
      (tester) async {
    final peticion = PeticionOracion(
      id: 'p1',
      userId: 'u1',
      userName: 'Ana',
      motivo: 'Orad por mi familia',
      fecha: DateTime.utc(2026, 1, 1),
      oracionesCount: 1,
    );

    await tester.pumpWidget(_harness(isGuest: false, peticiones: [peticion]));
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Orad por mi familia'), findsOneWidget);
    expect(find.text('1 orando'), findsOneWidget);
  });
}
