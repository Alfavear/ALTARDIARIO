import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/message.dart';
import '../data/models/usuario.dart';
import '../data/models/peticion_oracion.dart';

// Proveedor para StorageService (debe inicializarse en el main con un override)
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageProvider no ha sido inicializado');
});

// Proveedor para el estado de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Proveedor para el perfil del usuario actual
final userProfileProvider = StreamProvider<Usuario?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  if (uid == null) return Stream.value(null);
  
  return ref.watch(firestoreServiceProvider).getUsuario(uid);
});

// Proveedor para el servicio de Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Stream de reflexiones para el Feed
final reflexionesStreamProvider = StreamProvider((ref) {
  return ref.watch(firestoreServiceProvider).getReflexiones();
});

// Stream de reflexiones propias del usuario
final userReflexionesProvider = StreamProvider.family<List<Reflexion>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserReflexiones(userId);
});

// Stream de mensajes para un chat específico
final messagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(firestoreServiceProvider).getMessages(chatId);
});

// Stream de peticiones de oración
final peticionesStreamProvider = StreamProvider<List<PeticionOracion>>((ref) {
  return ref.watch(firestoreServiceProvider).getPeticionesOracion();
});