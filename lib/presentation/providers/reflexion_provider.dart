import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reflexion.dart';
import '../../services/firestore_service.dart';
import 'firestore_provider.dart';

final reflexionesStreamProvider = StreamProvider.autoDispose<List<Reflexion>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.reflexionesStream();
});

final reflexionesNotifierProvider = Provider<ReflexionesNotifier>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return ReflexionesNotifier(firestore);
});

class ReflexionesNotifier {
  final FirestoreService _firestore;

  ReflexionesNotifier(this._firestore);

  Future<void> publicarReflexion(String usuarioId, String texto) async {
    final reflexion = Reflexion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      usuarioId: usuarioId,
      texto: texto,
      fecha: DateTime.now(),
      likes: [],
      comentarios: [],
    );
    await _firestore.publicarReflexion(reflexion);
  }
}
