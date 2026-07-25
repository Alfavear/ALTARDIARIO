import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/storage_service.dart';
import '../../data/services/firestore_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/message.dart';
import '../../data/models/comment.dart';
import '../../data/models/debate.dart';
import '../../data/models/debate_reply.dart';
import '../../data/models/usuario.dart';
import '../../data/models/peticion_oracion.dart';
import '../../data/models/reflexion.dart';
import '../../core/services/notification_service.dart';

/// StorageService — se inicializa con override en main.dart
final storageProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
      'storageProvider no ha sido inicializado en el ProviderScope');
});

/// Servicio de autenticación.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Stream de cambios en el estado de autenticación (Firebase Auth).
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

/// UID local para modo demo/testing (sin Firebase).
class LocalUidNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setUid(String? uid) => state = uid;
}

final localUidProvider = NotifierProvider<LocalUidNotifier, String?>(LocalUidNotifier.new);

/// UID efectivo: Firebase Auth primero, luego modo local.
final effectiveUserUidProvider = Provider<String?>((ref) {
  final fbUid = ref.watch(authStateProvider).value?.uid;
  if (fbUid != null) return fbUid;
  return ref.watch(localUidProvider);
});

/// Servicio de Firestore.
final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Perfil del usuario autenticado en Firestore.
final userProfileProvider = StreamProvider<Usuario?>((ref) {
  final uid = ref.watch(effectiveUserUidProvider);
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
  final uid = ref.watch(effectiveUserUidProvider);
  return uid == authorId;
});

/// Lista de chats del usuario.
final chatListProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUserChats(userId);
});

/// Perfil de otro usuario (público).
final otherUserProfileProvider =
    StreamProvider.family<Usuario?, String>((ref, userId) {
  return ref.watch(firestoreServiceProvider).getUsuario(userId);
});

/// Datos de racha de un amigo para mostrar en ranking.
class FriendStreak {
  final String userId;
  final String nombre;
  final String fotoUrl;
  final int rachaActual;
  final int maxStreak;
  final int totalLecturas;
  FriendStreak({
    required this.userId,
    required this.nombre,
    required this.fotoUrl,
    required this.rachaActual,
    required this.maxStreak,
    required this.totalLecturas,
  });
}

/// Proveedor de rachas de amigos (usuarios que sigo + yo).
final friendStreaksProvider = FutureProvider<List<FriendStreak>>((ref) async {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return [];
  final firestore = ref.read(firestoreServiceProvider);
  final storage = ref.read(storageProvider);
  final usuario = await firestore.getUsuarioOnce(uid);
  if (usuario == null) return [];
  final allUids = [uid, ...usuario.siguiendo];
  final streaksData = await firestore.getStreaksData(allUids);
  final results = <FriendStreak>[];
  for (final id in allUids) {
    final data = streaksData[id];
    final progreso =
        data != null ? List<String>.from(data['progresoLectura']) : <String>[];
    final racha = storage.calcularRacha(progreso);
    final maxS = data != null ? (data['maxStreak'] as int? ?? 0) : 0;
    final nombre = data != null ? (data['nombre'] as String? ?? 'Anónimo') : 'Tú';
    final fotoUrl = data != null ? (data['fotoUrl'] as String? ?? '') : '';
    if (id == uid) {
      final localRacha = storage.calcularRacha();
      final localTotal = storage.getTotalCompletadas();
      results.insert(0, FriendStreak(
        userId: id,
        nombre: 'Tú',
        fotoUrl: '',
        rachaActual: localRacha,
        maxStreak: storage.getMaxStreak(),
        totalLecturas: localTotal,
      ));
    } else {
      results.add(FriendStreak(
        userId: id,
        nombre: nombre,
        fotoUrl: fotoUrl,
        rachaActual: racha,
        maxStreak: maxS,
        totalLecturas: progreso.length,
      ));
    }
  }
  results.sort((a, b) => b.rachaActual.compareTo(a.rachaActual));
  return results;
});

/// Verifica si el usuario actual sigue a otro usuario.
final isFollowingProvider = FutureProvider.family<bool, String>((ref, targetId) {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return Future.value(false);
  return ref.read(firestoreServiceProvider).getUsuarioOnce(uid).then((user) {
    return user?.siguiendo.contains(targetId) ?? false;
  });
});

/// Comentarios de una reflexión.
final comentariosStreamProvider =
    StreamProvider.family<List<Comment>, String>((ref, reflexionId) {
  return ref.watch(firestoreServiceProvider).comentariosStream(reflexionId);
});

/// Lista de usuarios que sigo.
final siguiendoUsuariosProvider =
    FutureProvider.family<List<Usuario>, String>((ref, uid) {
  return ref.read(firestoreServiceProvider).getSiguiendoUsuarios(uid);
});

/// Lista de seguidores.
final seguidoresUsuariosProvider =
    FutureProvider.family<List<Usuario>, String>((ref, uid) {
  return ref.read(firestoreServiceProvider).getSeguidoresUsuarios(uid);
});

/// Stream de debates bíblicos.
final debatesStreamProvider =
    StreamProvider.family<List<Debate>, String?>((ref, libroId) {
  return ref.watch(firestoreServiceProvider).debatesStream(libroId: libroId);
});

/// Stream de respuestas de un debate.
final debateRepliesStreamProvider =
    StreamProvider.family<List<DebateReply>, String>((ref, debateId) {
  return ref.watch(firestoreServiceProvider).debateRepliesStream(debateId);
});

/// Sugerencias de amistad (usuarios que no sigues).
final sugerenciasAmistadProvider =
    FutureProvider<List<Usuario>>((ref) async {
  final uid = ref.watch(effectiveUserUidProvider);
  if (uid == null) return [];
  final firestore = ref.read(firestoreServiceProvider);
  final usuario = await firestore.getUsuarioOnce(uid);
  if (usuario == null) return [];
  final excludeIds = <String>{uid, ...usuario.siguiendo};
  final allUsers = await firestore.getAllUsuarios();
  allUsers.shuffle();
  return allUsers.where((u) => !excludeIds.contains(u.id)).take(5).toList();
});

/// Modo Enfoque — sincronizado con Firestore (nivel usuario) y local.
class FocusModeNotifier extends Notifier<bool> {
  bool _initialSyncDone = false;

  @override
  bool build() {
    final storage = ref.watch(storageProvider);
    if (!_initialSyncDone) {
      _initialSyncDone = true;
      _syncFromFirestore();
    }
    return storage.getFocusMode();
  }

  Future<void> _syncFromFirestore() async {
    try {
      final uid = ref.read(effectiveUserUidProvider);
      if (uid == null) return;
      final firestore = ref.read(firestoreServiceProvider);
      final storage = ref.read(storageProvider);
      final usuario = await firestore.getUsuarioOnce(uid);
      if (usuario == null) return;
      // Sync focus mode
      if (usuario.modoEnfoque != state) {
        state = usuario.modoEnfoque;
        await storage.setFocusMode(usuario.modoEnfoque);
      }
      // Sync notification time from Firestore
      final localHour = storage.getNotificationHour();
      final localMin = storage.getNotificationMinute();
      if (usuario.notifHour != localHour || usuario.notifMin != localMin) {
        await storage.setNotificationTime(usuario.notifHour, usuario.notifMin);
        await NotificationService.cancelAll();
        if (!usuario.modoEnfoque) {
          await NotificationService.scheduleDailyReminder(
            hour: usuario.notifHour,
            minute: usuario.notifMin,
          );
        }
      }
    } catch (_) {}
  }

  Future<void> toggle() async {
    final storage = ref.read(storageProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final uid = ref.read(effectiveUserUidProvider);
    final newValue = !state;
    state = newValue;
    await storage.setFocusMode(newValue);
    if (uid != null) {
      await firestore.updateUserConfig(uid, {'modoEnfoque': newValue});
    }
    if (newValue) {
      await NotificationService.cancelAll();
    } else {
      await NotificationService.scheduleDailyReminder(
        hour: storage.getNotificationHour(),
        minute: storage.getNotificationMinute(),
      );
    }
  }
}

final focusModeProvider =
    NotifierProvider<FocusModeNotifier, bool>(FocusModeNotifier.new);
