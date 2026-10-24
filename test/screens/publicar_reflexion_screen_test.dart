import 'package:altar_diario/data/models/reflexion.dart';
import 'package:altar_diario/data/services/auth_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/features/reflexion/data/borrador_reflexion_store.dart';
import 'package:altar_diario/features/reflexion/presentation/vista_previa_reflexion.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/presentation/screens/publicar_reflexion_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PublicarReflexionScreen', () {
    late StorageService mockStorage;
    late MockFirestoreService mockFirestore;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      mockStorage = StorageService(prefs);
      mockFirestore = MockFirestoreService();
    });

    /// Abre la pantalla navegando desde una página anfitriona, como en la
    /// app real (Feed o Notas → PublicarReflexionScreen). Al publicar, la
    /// pantalla hace Navigator.pop de vuelta al anfitrión y es el Scaffold
    /// del anfitrión el que muestra el SnackBar de confirmación.
    Future<void> abrirPantalla(
      WidgetTester tester, {
      String? textoInicial,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageProvider.overrideWithValue(mockStorage),
            authServiceProvider.overrideWithValue(MockAuthService()),
            authStateProvider.overrideWithValue(const AsyncValue.data(null)),
            localUidProvider.overrideWith(
              () => _MockLocalUidNotifier('demo_user'),
            ),
            effectiveUserUidProvider.overrideWithValue('demo_user'),
            isGuestUserProvider.overrideWithValue(false),
            firestoreServiceProvider.overrideWithValue(mockFirestore),
            userProfileProvider.overrideWithValue(const AsyncValue.data(null)),
          ],
          child: MaterialApp(
            home: _AnfitrionDeNavegacion(textoInicial: textoInicial),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Sanidad: solo están los dos campos de la pantalla (pasaje y cuerpo).
      expect(find.byType(TextField), findsNWidgets(2));
    }

    testWidgets(
      'textoInicial precarga el cuerpo sin anunciar borrador recuperado',
      (tester) async {
        await abrirPantalla(
          tester,
          textoInicial: 'Nota convertida en reflexión',
        );

        expect(find.text('Nota convertida en reflexión'), findsOneWidget);
        // textoInicial llega desde Notas: no es un borrador recuperado, así
        // que el SnackBar no debe aparecer.
        expect(find.text('Borrador recuperado'), findsNothing);
      },
    );

    testWidgets(
      'un borrador guardado muestra "Borrador recuperado" y precarga el texto',
      (tester) async {
        await BorradorReflexionStore().guardar(
          const BorradorReflexion(
            texto: 'Borrador escrito antes de cerrar la app',
            pasaje: 'Juan 3:16',
          ),
        );

        await abrirPantalla(tester);

        expect(find.text('Borrador recuperado'), findsOneWidget);
        expect(
          find.text('Borrador escrito antes de cerrar la app'),
          findsOneWidget,
        );

        // Cierra el SnackBar por completo (incluye su temporizador).
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '"Guardar" abre VistaPreviaReflexion con pasaje y texto exactos',
      (tester) async {
        await abrirPantalla(tester);

        await tester.enterText(
          find.byType(TextField).at(1),
          'El Señor es mi pastor; nada me faltará.',
        );
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();

        final hoja = find.byType(VistaPreviaReflexion);
        expect(hoja, findsOneWidget);
        expect(
          find.descendant(of: hoja, matching: find.text('Salmo 23')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: hoja,
            matching: find.text('El Señor es mi pastor; nada me faltará.'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      '"Publicar" navega atrás y muestra el SnackBar "¡Reflexión compartida!"',
      (tester) async {
        await abrirPantalla(tester);

        await tester.enterText(
          find.byType(TextField).at(1),
          'El Señor es mi pastor; nada me faltará.',
        );
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Publicar'));
        await tester.pumpAndSettle();

        // Navega atrás: la pantalla desaparece y vuelve el anfitrión.
        expect(find.byType(PublicarReflexionScreen), findsNothing);
        expect(find.text('abrir'), findsOneWidget);
        expect(find.text('¡Reflexión compartida!'), findsOneWidget);

        // La publicación fue a los mocks (sin Firebase real) con el
        // contenido exacto, y el progreso se sincronizó una sola vez.
        expect(mockFirestore.publicaciones, hasLength(1));
        expect(
          mockFirestore.publicaciones.single.texto,
          'El Señor es mi pastor; nada me faltará.',
        );
        expect(mockFirestore.publicaciones.single.pasajeDia, 'Salmo 23');
        expect(mockFirestore.sincronizacionesDeProgreso, 1);

        // Cierra el SnackBar por completo (incluye su temporizador).
        await tester.pump(const Duration(seconds: 5));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      '"Seguir editando" cierra la vista previa y permite seguir escribiendo',
      (tester) async {
        await abrirPantalla(tester);

        await tester.enterText(
          find.byType(TextField).at(1),
          'Mi primera versión',
        );
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Seguir editando'));
        await tester.pumpAndSettle();

        // La hoja se cierra y no se publicó nada.
        expect(find.byType(VistaPreviaReflexion), findsNothing);
        expect(mockFirestore.publicaciones, isEmpty);

        // El cuerpo sigue editable: se puede seguir escribiendo.
        await tester.enterText(
          find.byType(TextField).at(1),
          'Versión ampliada tras seguir editando',
        );
        await tester.pump();
        expect(
          find.text('Versión ampliada tras seguir editando'),
          findsOneWidget,
        );
      },
    );
  });
}

/// Página anfitriona desde la que se navega a la pantalla, como hace el
/// Feed en la app real.
class _AnfitrionDeNavegacion extends StatelessWidget {
  final String? textoInicial;

  const _AnfitrionDeNavegacion({this.textoInicial});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicarReflexionScreen(
                pasajeDia: 'Salmo 23',
                textoInicial: textoInicial,
              ),
            ),
          ),
          child: const Text('abrir'),
        ),
      ),
    );
  }
}

class _MockLocalUidNotifier extends LocalUidNotifier {
  final String _uid;

  _MockLocalUidNotifier(this._uid);

  @override
  String? build() => _uid;
}

/// AuthService de mentira: sin Firebase. `currentUser` es null, así que el
/// nombre del autor cae al respaldo de StorageService ("Invitado").
class MockAuthService extends AuthService {
  @override
  User? get currentUser => null;
}

/// FirestoreService de mentira: registra lo publicado para verificar el
/// flujo sin tocar Firebase real. El resto de métodos heredan los guards
/// `if (!_available) return` del constructor base.
class MockFirestoreService extends FirestoreService {
  final List<Reflexion> publicaciones = [];
  int sincronizacionesDeProgreso = 0;

  @override
  Future<void> publicarReflexion(Reflexion reflexion) async {
    publicaciones.add(reflexion);
  }

  @override
  Future<void> syncProgress(
    String userId,
    List<String> completedDates,
    int maxStreak,
  ) async {
    sincronizacionesDeProgreso++;
  }
}
