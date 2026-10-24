import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../presentation/providers/app_providers.dart';

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

/// Stream de todas las peticiones de oración (filtrado: sin bloqueados ni ocultos).
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosActualProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(oracionRepositoryProvider)
          .peticionesStream()
          .map((peticiones) {
        return peticiones.where((p) {
          final isBlocked = blockedIds.contains(p.userId);
          final isHidden = p.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) => ref
        .watch(oracionRepositoryProvider)
        .peticionesStream()
        .map((p) => p.where((p) => p.oculto != true).toList()),
  );
});

/// Stream de peticiones filtradas por estado (respondida/pendiente) y sin bloqueados/ocultos.
final peticionesFiltradasProvider =
    StreamProvider<List<PeticionOracion>>((ref) {
  final filtro = ref.watch(peticionesFiltroProvider);
  final _ = ref.watch(effectiveUserUidProvider);
  final AsyncValue<List<String>> blockedAsync =
      ref.watch(usuariosBloqueadosActualProvider);
  return blockedAsync.when<Stream<List<PeticionOracion>>>(
    data: (blocked) {
      final blockedIds = blocked.toSet();
      return ref
          .watch(oracionRepositoryProvider)
          .peticionesStreamFiltrado(
            respondida: filtro,
          )
          .map((peticiones) {
        return peticiones.where((p) {
          final isBlocked = blockedIds.contains(p.userId);
          final isHidden = p.oculto == true;
          return !isBlocked && !isHidden;
        }).toList();
      });
    },
    loading: () => ref
        .watch(oracionRepositoryProvider)
        .peticionesStreamFiltrado(respondida: filtro)
        .map((p) => p.where((p) => p.oculto != true).toList()),
    error: (_, __) => ref
        .watch(oracionRepositoryProvider)
        .peticionesStreamFiltrado(respondida: filtro)
        .map((p) => p.where((p) => p.oculto != true).toList()),
  );
});
