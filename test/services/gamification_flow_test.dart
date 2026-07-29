import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/core/services/gamification_service.dart';
import 'package:altar_diario/data/models/usuario.dart';
import 'package:altar_diario/data/services/storage_service.dart';
import 'package:altar_diario/data/services/firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GamificationFlow', () {
    late SharedPreferences prefs;
    late StorageService storage;
    late MockFirestoreService firestore;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'completed_dates': ['2026-07-27'],
        'max_streak': 7,
      });
      prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
      firestore = MockFirestoreService();
    });

    final mockUser = Usuario(
      id: 'u1',
      nombre: 'Usuario Prueba',
      email: 'test@test.com',
      fotoUrl: '',
      bio: 'Prueba',
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

    test('evaluarYNotificarBadges otorga insignias de racha y lecturas cuando se cumplen los criterios', () async {
      final newBadges = await GamificationService.evaluarYNotificarBadges(
        user: mockUser,
        firestore: firestore,
        storage: storage,
        extraStats: {'rachaActual': 7},
      );

      expect(newBadges, isNotEmpty);
      final ids = newBadges.map((b) => b.id).toList();
      expect(ids, contains('primer_paso'));
      expect(ids, contains('semana_fiel'));
    });

    test('evaluarYNotificarBadges no duplica insignias ya desbloqueadas', () async {
      final userWithBadges = Usuario(
        id: 'u1',
        nombre: 'Usuario Prueba',
        email: 'test@test.com',
        fotoUrl: '',
        bio: 'Prueba',
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

      final newBadges = await GamificationService.evaluarYNotificarBadges(
        user: userWithBadges,
        firestore: firestore,
        storage: storage,
      );

      expect(newBadges.where((b) => b.id == 'primer_paso'), isEmpty);
      expect(newBadges.where((b) => b.id == 'semana_fiel'), isEmpty);
    });
  });
}

class MockFirestoreService extends FirestoreService {
  @override
  Future<void> updateUserConfig(String uid, Map<String, dynamic> config) async {}
}
