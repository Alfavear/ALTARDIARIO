import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/features/oracion/data/oracion_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier para el filtro de peticiones (todas/respondidas/pendientes).
class PeticionesFiltroNotifier extends Notifier<bool?> {
  @override
  bool? build() => null;

  void setFiltro(bool? value) => state = value;
}

/// Filtro actual para las peticiones (null = todas, true = respondidas, false = pendientes).
final peticionesFiltroProvider =
    NotifierProvider<PeticionesFiltroNotifier, bool?>(
        PeticionesFiltroNotifier.new);

/// Stream de todas las peticiones de oración.
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  return ref.watch(oracionRepositoryProvider).peticionesStream();
});

/// Stream de peticiones filtradas por estado (respondida/pendiente).
final peticionesFiltradasProvider =
    StreamProvider<List<PeticionOracion>>((ref) {
  final filtro = ref.watch(peticionesFiltroProvider);
  return ref.watch(oracionRepositoryProvider).peticionesStreamFiltrado(
        respondida: filtro,
      );
});
