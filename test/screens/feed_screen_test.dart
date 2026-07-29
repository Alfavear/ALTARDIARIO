import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/screens/feed_screen.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/data/models/reflexion.dart';
import 'package:altar_diario/data/models/comment.dart';
import 'package:altar_diario/data/models/usuario.dart';
import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FeedScreen', () {
    late SharedPreferences prefs;
    late StorageService mockStorage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      mockStorage = StorageService(prefs);
      await mockStorage.loadPlan();
    });

    final mockReflexiones = [
      Reflexion(
        id: 'r1',
        userId: 'u1',
        userName: 'Juan Pérez',
        texto: 'Dios me habló hoy sobre la paciencia...',
        pasajeDia: 'Santiago 1:2-4',
        fecha: DateTime.now(),
        likes: 5,
        likedBy: ['u2', 'u3'],
        commentCount: 3,
        reactions: {'u1': '❤️', 'u2': '🙏'},
        tags: ['paciencia', 'fe'],
      ),
      Reflexion(
        id: 'r2',
        userId: 'u2',
        userName: 'María García',
        texto: 'Qué bendición este pasaje...',
        pasajeDia: 'Romanos 8:28',
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
        likes: 12,
        likedBy: ['u1', 'u3', 'u4'],
        commentCount: 1,
        reactions: {'u3': '🔥'},
        tags: ['bendición', 'esperanza'],
      ),
    ];

    testWidgets('renderiza FeedScreen con reflexiones', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            userProfileProvider.overrideWithValue(AsyncValue.data(null)),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Altar Comunitario'), findsOneWidget);
      expect(find.text('Dios me habló hoy sobre la paciencia...'), findsOneWidget);
      expect(find.text('Qué bendición este pasaje...'), findsOneWidget);
      expect(find.text('Santiago 1:2-4'), findsOneWidget);
      expect(find.text('Romanos 8:28'), findsOneWidget);
    });

    testWidgets('busca por texto en reflexiones', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            userProfileProvider.overrideWithValue(AsyncValue.data(null)),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Escribir en el buscador
      await tester.enterText(find.byType(TextField), 'paciencia');
      await tester.pumpAndSettle();

      // Solo debe mostrar la primera reflexión
      expect(find.text('Dios me habló hoy sobre la paciencia...'), findsOneWidget);
      expect(find.text('Qué bendición este pasaje...'), findsNothing);
    });

    testWidgets('filtra por tag', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            userProfileProvider.overrideWithValue(AsyncValue.data(null)),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );

      await tester.pumpAndSettle();

// Seleccionar tag "Esperanza" - buscar el chip de filtro
       final tagChip = find.text('Esperanza').first;
       await tester.tap(tagChip);
       await tester.pumpAndSettle();

       expect(find.text('Qué bendición este pasaje...'), findsOneWidget);
       expect(find.text('Dios me habló hoy sobre la paciencia...'), findsNothing);
    });

    testWidgets('muestra estado vacío cuando no hay reflexiones', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            reflexionesStreamProvider.overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            userProfileProvider.overrideWithValue(AsyncValue.data(null)),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aún no hay reflexiones'), findsOneWidget);
      expect(find.text('¡Sé el primero en compartir tu devocional!'), findsOneWidget);
    });

    testWidgets('FAB navega a PublicarReflexionScreen', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('demo_user')),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            reflexionesStreamProvider.overrideWithValue(AsyncValue.data(mockReflexiones)),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            userProfileProvider.overrideWithValue(AsyncValue.data(null)),
          ],
          child: const MaterialApp(home: FeedScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // El FAB existe en la pantalla
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

// Verificar que navegó (ya no está en FeedScreen)
       expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}

class _MockLocalUidNotifier extends LocalUidNotifier {
  final String _uid;
  _MockLocalUidNotifier(this._uid);

  @override
  String? build() => _uid;
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
}