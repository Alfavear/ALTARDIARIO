import 'dart:async';

import 'package:altar_diario/data/models/comment.dart';
import 'package:altar_diario/data/models/peticion_oracion.dart';
import 'package:altar_diario/data/models/reflexion.dart';
import 'package:altar_diario/data/models/usuario.dart';
import 'package:altar_diario/data/services/auth_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/l10n/generated/app_localizations.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/presentation/screens/login_screen.dart';
import 'package:altar_diario/presentation/screens/perfil_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    testWidgets('renderiza PerfilScreen con Nivel, XP y sección Mis Insignias',
        (tester) async {
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
            userReflexionesProvider('u1')
                .overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(
            home: PerfilScreen(),
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
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

    testWidgets('al pulsar Ver todas abre modal con la colección de insignias',
        (tester) async {
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
            userReflexionesProvider('u1')
                .overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(
            home: PerfilScreen(),
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
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

    testWidgets('al pulsar el avatar abre dialogo de edicion de perfil',
        (tester) async {
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
            userReflexionesProvider('u1')
                .overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(
            home: PerfilScreen(),
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
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

  group('PerfilScreen Borrado de cuenta', () {
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
      nombre: 'Usuario Borrado',
      email: 'borrar@test.com',
      fotoUrl: '',
      bio: '',
      fechaCreacion: DateTime.now(),
      siguiendo: [],
      seguidores: [],
      badges: [],
      totalPuntos: 0,
      nivel: 1,
      modoEnfoque: false,
      notifHour: 20,
      notifMin: 0,
    );

    // Usuario anónimo: salta el bloque de reautenticación y va directo a borrar.
    final authUserAnonimo =
        MockUser(uid: 'u1', isAnonymous: true, photoURL: '');
    // Usuario con Google: entra en el bloque de reautenticación con Google.
    final authUserGoogle = MockUser(
      uid: 'u1',
      providerData: [const _FakeUserInfo(providerId: 'google.com')],
      photoURL: '',
    );

    Future<void> abrirConfirmacionYBorrar(WidgetTester tester) async {
      final eliminar = find.byIcon(Icons.delete_outline);
      expect(eliminar, findsOneWidget);
      await tester.tap(eliminar);
      await tester.pumpAndSettle();
      final confirmar = find.text('Eliminar cuenta');
      expect(confirmar, findsOneWidget);
      await tester.tap(confirmar);
      await tester.pumpAndSettle();
    }

    testWidgets('borrado exitoso navega a LoginScreen', (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider
                .overrideWithValue(AsyncValue.data(authUserAnonimo)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
            effectiveUserUidProvider.overrideWithValue('u1'),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            userReflexionesProvider('u1')
                .overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            // ignore: argument_type_not_assignable
            authServiceProvider.overrideWithValue(MockAuthServiceOk()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(
            home: PerfilScreen(),
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await abrirConfirmacionYBorrar(tester);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Cuenta eliminada correctamente'), findsOneWidget);
    });

    testWidgets('reautenticación fallida no navega a login ni borra la cuenta',
        (tester) async {
      tester.view.physicalSize = const Size(1000, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authStateProvider
                .overrideWithValue(AsyncValue.data(authUserGoogle)),
            localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
            effectiveUserUidProvider.overrideWithValue('u1'),
            userProfileProvider.overrideWithValue(AsyncValue.data(mockUsuario)),
            userReflexionesProvider('u1')
                .overrideWithValue(const AsyncValue.data([])),
            firestoreServiceProvider.overrideWithValue(MockFirestoreService()),
            // ignore: argument_type_not_assignable
            authServiceProvider.overrideWithValue(MockAuthServiceFallaReauth()),
            focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
          ],
          child: const MaterialApp(
            home: PerfilScreen(),
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await abrirConfirmacionYBorrar(tester);

      expect(find.byType(LoginScreen), findsNothing);
      expect(
        find.text(
            'Tu sesión ha expirado. Vuelve a iniciar sesión e inténtalo de nuevo.'),
        findsOneWidget,
      );
    });
  });

  group('PerfilScreen Bloqueados', () {
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

    /// Widget de prueba que muestra el diálogo de bloqueados directamente.
    Widget buildTestDialogApp({
      required Stream<List<String>> bloqueadosStream,
      required FirestoreService firestore,
    }) {
      return ProviderScope(
        overrides: [
          storageProvider.overrideWithValue(mockStorage),
          authStateProvider.overrideWithValue(const AsyncValue.data(null)),
          localUidProvider.overrideWith(() => _MockLocalUidNotifier('u1')),
          effectiveUserUidProvider.overrideWithValue('u1'),
          firestoreServiceProvider.overrideWithValue(firestore),
          focusModeProvider.overrideWith(() => _MockFocusModeNotifier(false)),
        ],
        child: MaterialApp(
          home: _TestBloqueadosDialogTrigger(
            bloqueadosStream: bloqueadosStream,
            firestore: firestore,
          ),
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets('muestra cargando mientras llega el stream', (tester) async {
      // Stream que tarda en emitir (simula loading)
      final streamController = StreamController<List<String>>();
      final firestore = MockFirestoreServiceBloqueados(
        bloqueadosStream: streamController.stream,
      );

      await tester.pumpWidget(buildTestDialogApp(
        bloqueadosStream: streamController.stream,
        firestore: firestore,
      ));

      // Toca el botón para abrir el diálogo
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // No pumpAndSettle porque el stream no emite aún

      // Mientras no se emite nada, debe mostrar loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Cargando bloqueados…'), findsOneWidget);
      expect(find.text('No tienes usuarios bloqueados.'), findsNothing);

      // Emitimos datos vacíos
      streamController.add([]);
      await tester.pumpAndSettle();

      // Ahora debe mostrar lista vacía
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No tienes usuarios bloqueados.'), findsOneWidget);

      await streamController.close();
    });

    testWidgets('muestra error con botón reintentar cuando el stream falla',
        (tester) async {
      final firestore = MockFirestoreServiceBloqueados(
        bloqueadosStream: _streamError(),
      );

      await tester.pumpWidget(buildTestDialogApp(
        bloqueadosStream: _streamError(),
        firestore: firestore,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Debe mostrar error con botón reintentar
      expect(
          find.text('No se pudieron cargar los bloqueados.'), findsOneWidget);
      expect(find.text('Comprueba tu conexión e inténtalo de nuevo.'),
          findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('muestra lista vacía cuando no hay bloqueados', (tester) async {
      final firestore = MockFirestoreServiceBloqueados(
        bloqueadosStream: Stream.value([]),
      );

      await tester.pumpWidget(buildTestDialogApp(
        bloqueadosStream: Stream.value([]),
        firestore: firestore,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('No tienes usuarios bloqueados.'), findsOneWidget);
    });

    testWidgets('no hace overflow con 20 bloqueados', (tester) async {
      final veinteUids = List.generate(20, (i) => 'uid$i');
      final firestore = MockFirestoreServiceBloqueados(
        bloqueadosStream: Stream.value(veinteUids),
      );

      // Tamaño de pantalla pequeño para forzar scroll
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestDialogApp(
        bloqueadosStream: Stream.value(veinteUids),
        firestore: firestore,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Debe renderizar los 20 ListTile sin overflow
      expect(find.byType(ListTile), findsNWidgets(20));
      // Verifica que no hay overflow (el test fallaría si lo hubiera)
      expect(tester.takeException(), isNull);
    });

    testWidgets('no hace overflow con textScaler 2.0 y lista vacía',
        (tester) async {
      final firestore = MockFirestoreServiceBloqueados(
        bloqueadosStream: Stream.value([]),
      );

      // Pantalla pequeña + textScaler 2.0 (usando MediaQuery)
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: buildTestDialogApp(
            bloqueadosStream: Stream.value([]),
            firestore: firestore,
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('No tienes usuarios bloqueados.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Widget de prueba que muestra un botón para abrir el diálogo de bloqueados.
class _TestBloqueadosDialogTrigger extends ConsumerWidget {
  final Stream<List<String>> bloqueadosStream;
  final FirestoreService firestore;

  const _TestBloqueadosDialogTrigger({
    required this.bloqueadosStream,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showBloqueadosDialogDirect(
              context, ref, firestore, bloqueadosStream),
          child: const Text('Abrir diálogo'),
        ),
      ),
    );
  }
}

/// Versión directa del diálogo para testing (copia la lógica de _showBloqueadosDialog).
void _showBloqueadosDialogDirect(BuildContext context, WidgetRef ref,
    FirestoreService firestore, Stream<List<String>> bloqueadosStream) {
  const uid = 'u1';

  unawaited(
    showDialog<void>(
      context: context,
      builder: (ctx) => StreamBuilder<List<String>>(
        stream: bloqueadosStream,
        builder: (context, snapshot) {
          // Estados de carga y error — distintos de lista vacía
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const BloqueadosDialogContent(
              title: 'Usuarios bloqueados',
              child: BloqueadosLoading(),
            );
          }
          if (snapshot.hasError) {
            return BloqueadosDialogContent(
              title: 'Usuarios bloqueados',
              child: BloqueadosError(
                onRetry: () {
                  Navigator.of(ctx).pop();
                  _showBloqueadosDialogDirect(
                      context, ref, firestore, bloqueadosStream);
                },
              ),
            );
          }

          final List<String> bloqueados = snapshot.data ?? <String>[];
          return BloqueadosDialogContent(
            title: 'Usuarios bloqueados',
            child: BloqueadosList(
              bloqueados: bloqueados,
              firestore: firestore,
              uid: uid,
            ),
          );
        },
      ),
    ),
  );
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
  Stream<List<Comment>> comentariosStream(String reflexionId) =>
      Stream.value([]);

  @override
  Stream<List<PeticionOracion>> peticionesStream() => Stream.value([]);

  @override
  Future<void> toggleLike(
      String reflexionId, String userId, bool isLiked) async {}

  @override
  Future<void> toggleReaction(String reflexionId, String userId, String? emoji,
      String? currentEmoji) async {}

  @override
  Future<void> publicarComentario(Comment comment) async {}

  @override
  Future<void> toggleCommentLike(String reflexionId, String commentId,
      String userId, bool isLiked) async {}

  @override
  Future<void> toggleFollow(
      String currentUserId, String targetUserId, bool isFollowing) async {}

  @override
  Future<Usuario?> getUsuarioOnce(String uid) async => null;

  @override
  Future<void> updateUserConfig(
      String uid, Map<String, dynamic> config) async {}

  @override
  Future<Map<String, Map<String, dynamic>>> getStreaksData(
          List<String> uids) async =>
      {};

  @override
  Future<List<Usuario>> getAllUsuarios() async => [];
}

/// Stream que emite error inmediato.
Stream<List<String>> _streamError() async* {
  throw Exception('Error de red simulado');
}

/// Mock de FirestoreService que permite controlar el stream de bloqueados.
class MockFirestoreServiceBloqueados extends MockFirestoreService {
  final Stream<List<String>> bloqueadosStream;

  MockFirestoreServiceBloqueados({required this.bloqueadosStream});

  @override
  Stream<List<String>> getUsuariosBloqueados(String uid) => bloqueadosStream;

  @override
  Future<Usuario?> getUsuarioOnce(String uid) async {
    // Retorna un usuario mock para cada UID bloqueado
    return Usuario(
      id: uid,
      nombre: 'Usuario $uid',
      email: '$uid@test.com',
      fotoUrl: '',
      bio: 'Biografía de $uid',
      fechaCreacion: DateTime.now(),
      siguiendo: [],
      seguidores: [],
      badges: [],
      totalPuntos: 0,
      nivel: 1,
      modoEnfoque: false,
      notifHour: 20,
      notifMin: 0,
    );
  }
}

/// AuthService mock donde la reautenticación y el borrado tienen éxito.
// ignore: extends_non_class
class MockAuthServiceOk extends AuthService {
  MockAuthServiceOk();

  // ignore: override_on_non_overriding_member
  @override
  // ignore: override_on_non_overriding_member
  Future<AuthCredential> reauthenticateWithGoogle() async =>
      GoogleAuthProvider.credential(idToken: 'tok', accessToken: 'acc');

  // ignore: override_on_non_overriding_member
  @override
  // ignore: override_on_non_overriding_member
  Future<void> reauthenticate(AuthCredential credential) async {}

  // ignore: override_on_non_overriding_member
  @override
  // ignore: override_on_non_overriding_member
  Future<void> deleteCurrentUser() async {}
}

/// Implementación mínima de UserInfo para tests de reautenticación.
class _FakeUserInfo implements UserInfo {
  // ignore: override_on_non_overriding_member
  @override
  final String providerId;
  // ignore: override_on_non_overriding_member
  @override
  final String? uid = null;
  // ignore: override_on_non_overriding_member
  @override
  final String? displayName = null;
  // ignore: override_on_non_overriding_member
  @override
  final String? photoURL = null;
  // ignore: override_on_non_overriding_member
  @override
  final String? email = null;
  // ignore: override_on_non_overriding_member
  @override
  final String? phoneNumber = null;

  const _FakeUserInfo({required this.providerId});
}

/// AuthService mock donde la reautenticación falla (p. ej. sesión expirada).
// ignore: extends_non_class
class MockAuthServiceFallaReauth extends AuthService {
  MockAuthServiceFallaReauth();

  // ignore: override_on_non_overriding_member
  @override
  // ignore: override_on_non_overriding_member
  Future<AuthCredential> reauthenticateWithGoogle() async {
    throw FirebaseAuthException(code: 'requires-recent-login', message: 'req');
  }
}

/// Contenedor común del diálogo para testing (copia de _BloqueadosDialogContent).
class BloqueadosDialogContent extends StatelessWidget {
  final String title;
  final Widget child;

  const BloqueadosDialogContent({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    return AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(child: child),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// Estado: cargando la lista de bloqueados (copia de _BloqueadosLoading).
class BloqueadosLoading extends StatelessWidget {
  const BloqueadosLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.maxFinite,
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando bloqueados…'),
          ],
        ),
      ),
    );
  }
}

/// Estado: error al cargar — mensaje humano + botón Reintentar (copia de _BloqueadosError).
class BloqueadosError extends StatelessWidget {
  final VoidCallback onRetry;

  const BloqueadosError({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar los bloqueados.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Comprueba tu conexión e inténtalo de nuevo.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

/// Estado: lista (vacía o con usuarios) (copia de _BloqueadosList).
class BloqueadosList extends StatelessWidget {
  final List<String> bloqueados;
  final FirestoreService firestore;
  final String uid;

  const BloqueadosList({
    super.key,
    required this.bloqueados,
    required this.firestore,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    if (bloqueados.isEmpty) {
      return const SizedBox(
        width: double.maxFinite,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No tienes usuarios bloqueados.'),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final String bloqueadoUid in bloqueados)
          FutureBuilder<Usuario?>(
            future: firestore.getUsuarioOnce(bloqueadoUid),
            builder: (context, userSnapshot) {
              final Usuario? usuario = userSnapshot.data;
              if (usuario == null) {
                return const SizedBox.shrink();
              }
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: usuario.fotoUrl.isNotEmpty
                      ? NetworkImage(usuario.fotoUrl)
                      : null,
                  child:
                      usuario.fotoUrl.isEmpty ? const Icon(Icons.person) : null,
                ),
                title: Text(usuario.nombre),
                subtitle: Text(usuario.bio),
                trailing: TextButton(
                  onPressed: () async {
                    await firestore.desbloquearUsuario(uid, bloqueadoUid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Usuario desbloqueado')));
                    }
                  },
                  child: const Text('Desbloquear'),
                ),
              );
            },
          ),
      ],
    );
  }
}
