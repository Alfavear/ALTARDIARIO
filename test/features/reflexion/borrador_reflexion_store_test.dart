import 'package:altar_diario/features/reflexion/data/borrador_reflexion_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('guarda y recupera el borrador con su pasaje', () async {
    final store = BorradorReflexionStore();

    await store.guardar(
      const BorradorReflexion(texto: 'Una idea a medias', pasaje: 'Juan 3:16'),
    );
    final leido = await store.leer();

    expect(leido, isNotNull);
    expect(leido!.texto, 'Una idea a medias');
    expect(leido.pasaje, 'Juan 3:16');
    expect(leido.vacio, isFalse);
  });

  test('un borrador en blanco no se considera recuperable', () async {
    final store = BorradorReflexionStore();

    await store.guardar(const BorradorReflexion(texto: '   ', pasaje: ''));
    expect(await store.leer(), isNull);
  });

  test('sin nada guardado devuelve null', () async {
    expect(await BorradorReflexionStore().leer(), isNull);
  });

  test('borrar deja el almacenamiento limpio', () async {
    final store = BorradorReflexionStore();
    await store.guardar(
      const BorradorReflexion(texto: 'Texto', pasaje: 'Salmo 1'),
    );

    await store.borrar();

    expect(await store.leer(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(BorradorReflexionStore.claveTexto), isNull);
    expect(prefs.getString(BorradorReflexionStore.clavePasaje), isNull);
  });
}
