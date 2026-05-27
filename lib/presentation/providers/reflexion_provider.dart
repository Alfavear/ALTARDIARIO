import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reflexion.dart';
import '../../data/services/firestore_service.dart'; // Correcto
import 'app_providers.dart'; // Correcto

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

  Future<void> publicarReflexion({
    required String userId,
    required String userName,
    required String texto,
    required String pasajeDia,
  }) async {
    final reflexion = Reflexion(
      id: '', // Firestore genera el ID automáticamente
      userId: userId,
      userName: userName,
      texto: texto,
      pasajeDia: pasajeDia,
      fecha: DateTime.now(),
      likes: 0,
    );
    await _firestore.publicarReflexion(reflexion);
  }
}
