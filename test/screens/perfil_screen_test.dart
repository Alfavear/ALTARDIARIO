import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/screens/perfil_screen.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/data/models/usuario.dart';
import 'package:altar_diario/data/models/reflexion.dart';
import 'package:altar_diario/data/models/comment.dart';
import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PerfilScreen Gamificación', () {
    late SharedPreferences prefs;
    late StorageService mockStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'completed_dates': ['2026-07-27'],
        'max_streak': 1,
        'notification_hour': 20,
        'notification_minute': 0,
        'focus_mode_enabled': false,
      });
      prefs = await SharedPreferences.getInstance();
      mockStorage = StorageService(prefs);
    });

    final mockUsuario = Usuario(
      id: 'u1',
      nombre: 'Usuario Gamificado',
      email: 'gamer@test.com',
      fotoUrl: '',
      bio: 'Perfil de prueba con insignias',
      fechaCreacion: DateTime.now(),
      siguiendo: [],
      seguidores: [],
      badges: ['primer_paso', 'semana_fiel'],
      totalPuntos: 60,
      nivel: 1,
      modoEnfoque: false,
      notifHour: 20,
      notifMin: 0,
    );

    testWidgets('renderiza PerfilScreen con Nivel, XP y sección Mis Insignias', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
            effectiveUserUidProvider.overrideWithValue('u1'),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            userReflexionesProvider('u1').overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(home: PerfilScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nivel 1'), findsOneWidget);
      expect(find.text('Progreso de XP'), findsOneWidget);
      expect(find.text('60 XP'), findsOneWidget);
      expect(find.text('Mis Insignias'), findsOneWidget);
      expect(find.text('Ver todas'), findsOneWidget);
      expect(find.text('Primer Paso'), findsOneWidget);
    });

    testWidgets('al pulsar Ver todas abre modal con la colección de insignias', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
            effectiveUserUidProvider.overrideWithValue('u1'),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            userReflexionesProvider('u1').overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(home: PerfilScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final verTodasBtn = find.text('Ver todas');
      expect(verTodasBtn, findsOneWidget);
      await tester.ensureVisible(verTodasBtn);
      await tester.tap(verTodasBtn);
      await tester.pumpAndSettle();

      expect(find.text('Colección de Insignias'), findsOneWidget);
    });

    testWidgets('al pulsar el avatar abre dialogo de edicion de perfil', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
            effectiveUserUidProvider.overrideWithValue('u1'),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            userReflexionesProvider('u1').overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(home: PerfilScreen()),
        ),
      );

      await tester.pumpAndSettle();

      final editIcon = find.byIcon(Icons.edit);
      expect(editIcon, findsWidgets);
      await tester.tap(editIcon.first);
      await tester.pumpAndSettle();

      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Nombre de usuario'), findsOneWidget);
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
