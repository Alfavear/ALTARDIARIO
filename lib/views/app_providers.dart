import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Proveedor para StorageService (debe inicializarse en el main con un override)
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageProvider no ha sido inicializado');
});

// Proveedor para el estado de autenticación
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Proveedor para el servicio de Firestore
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Stream de reflexiones para el Feed
final reflexionesStreamProvider = StreamProvider((ref) {
  return ref.watch(firestoreServiceProvider).getReflexiones();
});