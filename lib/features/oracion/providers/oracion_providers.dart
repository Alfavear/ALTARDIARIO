import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/peticion_oracion.dart';
import '../../../presentation/providers/app_providers.dart';
import '../data/oracion_repository.dart';

/// Repositorio de oración. Null si Firestore no está disponible (tests, bootstrap).
final oracionRepositoryProvider = Provider<OracionRepository?>((ref) {
  final db = ref.watch(firestoreServiceProvider).firestore;
  return db == null ? null : OracionRepository(db);
});

/// Peticiones de oración de la comunidad (sin filtrar).
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final repo = ref.watch(oracionRepositoryProvider);
  return repo?.watchRecientes() ?? Stream.value(const <PeticionOracion>[]);
});

class PeticionesFiltroNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void setFiltro(bool? value) => state = value;
}

/// Filtro actual (null = todas, true = respondidas, false = pendientes).
final peticionesFiltroProvider =
    NotifierProvider<PeticionesFiltroNotifier, bool?>(
        PeticionesFiltroNotifier.new);

/// Peticiones de oración filtradas por estado.
final peticionesFiltradasProvider =
    StreamProvider<List<PeticionOracion>>((ref) {
  final filtro = ref.watch(peticionesFiltroProvider);
  final repo = ref.watch(oracionRepositoryProvider);
  return repo?.watchFiltrado(respondida: filtro) ??
      Stream.value(const <PeticionOracion>[]);
});
