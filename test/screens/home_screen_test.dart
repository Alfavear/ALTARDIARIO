import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/screens/home_screen.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/data/models/reflexion.dart';
import 'package:altar_diario/data/models/usuario.dart';
import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/data/models/comment.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen', () {
    late SharedPreferences prefs;
    late StorageService mockStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'completed_dates': [],
        'max_streak': 0,
        'notification_hour': 20,
        'notification_minute': 0,
        'focus_mode_enabled': false,
      });
      prefs = await SharedPreferences.getInstance();
      mockStorage = StorageService(prefs);
      await mockStorage.loadPlan();
    });

    final mockUsuario = Usuario(
      id: 'u1',
      nombre: 'Usuario Demo',
      email: 'demo@test.com',
      fotoUrl: '',
      bio: 'Usuario de prueba',
      fechaCreacion: DateTime.now(),
      siguiendo: [],
      seguidores: [],
      modoEnfoque: false,
      notifHour: 20,
      notifMin: 0,
    );

    final mockReflexiones = [
      Reflexion(
        id: 'r1',
        userId: 'u2',
        userName: 'María',
        texto: 'Reflexión de prueba',
        pasajeDia: 'Salmo 23',
        fecha: DateTime.now(),
        likes: 3,
        likedBy: [],
        commentCount: 1,
        reactions: {},
        tags: [],
      ),
    ];

    testWidgets('renderiza HomeScreen con elementos principales', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            sugerenciasAmistadProvider.overrideWithValue(const AsyncValue.data([])),
            friendStreaksProvider.overrideWithValue(const AsyncValue.data([])),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: MediaQuery(
            data: const MediaQueryData(size: Size(1000, 1400)),
            child: const MaterialApp(home: HomeScreen()),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mi Lectura Hoy'), findsOneWidget);
      expect(find.text('AltarDiario'), findsOneWidget);
    });
  });
}

class _MockLocalUidNotifier extends LocalUidNotifier {
  final String _uid;
  _MockLocalUidNotifier(this._uid);

  @override
  String? build() => _uid;
}

class _MockFocusModeNotifier extends FocusModeNotifier {
  final bool _value;
  _MockFocusModeNotifier(this._value);

  @override
  bool build() => _value;
}

class MockFirestoreService extends FirestoreService {
  @override
  Stream<List<Reflexion>> reflexionesStream() => Stream.value([]);

  @override
  Stream<List<Reflexion>> getUserReflexiones(String userId) => Stream.value([]);

  @override
  Stream<List<Comment>> comentariosStream(String reflexionId) => Stream.value([]);

  @override
  Stream<List<PeticionOracion>> peticionesStream() => Stream.value([]);

  @override
  Future<void> toggleLike(String reflexionId, String userId, bool isLiked) async {}

  @override
  Future<void> toggleReaction(String reflexionId, String userId, String? emoji, String? currentEmoji) async {}

  @override
  Future<void> publicarComentario(Comment comment) async {}

  @override
  Future<void> toggleCommentLike(String reflexionId, String commentId, String userId, bool isLiked) async {}

  @override
  Future<void> toggleFollow(String currentUserId, String targetUserId, bool isFollowing) async {}

  @override
  Future<Usuario?> getUsuarioOnce(String uid) async => null;

  @override
  Future<void> updateUserConfig(String uid, Map<String, dynamic> config) async {}

  @override
  Future<Map<String, Map<String, dynamic>>> getStreaksData(List<String> uids) async => {};

  @override
  Future<List<Usuario>> getAllUsuarios() async => [];
}