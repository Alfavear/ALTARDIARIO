// Flujo crítico 1: la app arranca, pasa el splash y muestra la pantalla de
// login o el home. Ampliar con: login invitado → lectura del día → publicar.
//
// Ejecutar en dispositivo/emulador:
//   flutter test integration_test/app_test.dart -d <device>
import 'package:altar_diario/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('la app arranca y supera el splash sin errores', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 6));
    expect(tester.takeException(), isNull);
  });
}
