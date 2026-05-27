import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/storage_service.dart'; // Correcto
import '../../data/services/firestore_service.dart'; // Correcto
import '../../data/services/auth_service.dart'; // Correcto
import '../../data/models/message.dart'; // Correcto
import '../../data/models/usuario.dart'; // Correcto
import '../../data/models/peticion_oracion.dart'; // Correcto
import '../../data/models/reflexion.dart'; // Correcto

/// Proveedor para StorageService. 
/// Se inicializa con un UnimplementedError porque debe ser sobreescrito en el main.dart
/// una vez que SharedPreferences esté listo.
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageProvider no ha sido inicializado en el ProviderScope');
});

/// Proveedor para el servicio de autenticación.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream que escucha los cambios en el estado de autenticación de Firebase.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

/// Proveedor para el servicio de Firestore.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Proveedor para el perfil del usuario actual obtenido de Firestore.
final userProfileProvider = StreamProvider<Usuario?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  
  if (uid == null) return Stream.value(null);
  
  return ref.watch(firestoreServiceProvider).getUsuario(uid);
});

/// Stream de todas las reflexiones del Altar Comunitario.
final reflexionesStreamProvider = StreamProvider<List<Reflexion>>((ref) {
  return ref.watch(firestoreServiceProvider).reflexionesStream();
});

/// Stream de reflexiones filtradas por un usuario específico (para la pantalla de perfil).
final userReflexionesProvider = StreamProvider.family<List<Reflexion>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserReflexiones(userId);
});

/// Stream de peticiones de oración de la comunidad.
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  return ref.watch(firestoreServiceProvider).peticionesStream();
});

/// Stream de mensajes para una conversación de chat específica.
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(firestoreServiceProvider).getMessages(chatId);
});

/// Proveedor auxiliar para verificar si el usuario actual es el autor de un contenido.
final isAuthorProvider = Provider.family<bool, String>((ref, authorId) {
  final currentUser = ref.watch(authStateProvider).value;
  return currentUser?.uid == authorId;
});