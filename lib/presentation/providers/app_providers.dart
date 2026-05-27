import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/message.dart';
import '../../data/models/usuario.dart';
import '../../data/models/peticion_oracion.dart';
import '../../data/models/reflexion.dart';

/// StorageService — se inicializa con override en main.dart
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
      'storageProvider no ha sido inicializado en el ProviderScope');
});

/// Servicio de autenticación.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream de cambios en el estado de autenticación.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

/// Servicio de Firestore.
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Perfil del usuario autenticado en Firestore.
final userProfileProvider = StreamProvider<Usuario?>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return ref.watch(firestoreServiceProvider).getUsuario(uid);
});

/// Feed de reflexiones de la comunidad.
final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  return ref.watch(firestoreServiceProvider).reflexionesStream();
});

/// Reflexiones de un usuario específico (para su perfil).
final userReflexionesProvider =
    StreamProvider.family<List<Reflexion>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserReflexiones(userId);
});

/// Peticiones de oración de la comunidad.
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  return ref.watch(firestoreServiceProvider).peticionesStream();
});

/// Mensajes de un chat específico.
final messagesStreamProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(firestoreServiceProvider).getMessages(chatId);
});

/// Verifica si el usuario actual es el autor de un contenido.
final isAuthorProvider = Provider.family<bool, String>((ref, authorId) {
  final currentUser = ref.watch(authStateProvider).value;
  return currentUser?.uid == authorId;
});
