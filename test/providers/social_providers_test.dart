import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/presentation/providers/app_providers.dart';
import 'package:altar_diario/data/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService calcularRacha', () {
    late StorageService storage;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
      await storage.loadPlan();
    });

    test('sin fechas retorna 0', () {
      expect(storage.calcularRacha([]), 0);
    });

    test('solo hoy retorna 1', () {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      expect(storage.calcularRacha([todayStr]), 1);
    });

    test('hoy y ayer retorna 2', () {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';
      expect(storage.calcularRacha([todayStr, yesterdayStr]), 2);
    });

    test('salto de día rompe la racha', () {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final twoDaysAgoStr = '${twoDaysAgo.year}-${twoDaysAgo.month.toString().padLeft(2, '0')}-${twoDaysAgo.day.toString().padLeft(2, '0')}';
      
      // Hoy y anteayer (salto ayer)
      expect(storage.calcularRacha([todayStr, twoDaysAgoStr]), 1);
    });
  });

  group('Providers básicos', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWithValue(const AsyncValue.data(null)),
          effectiveUserUidProvider.overrideWithValue('user_123'),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('effectiveUserUidProvider usa local UID cuando no hay Firebase user', () {
      final effectiveUid = container.read(effectiveUserUidProvider);
      expect(effectiveUid, 'user_123');
    });

    test('isAuthorProvider compara UIDs correctamente', () {
      final isAuthor = container.read(isAuthorProvider('user_123'));
      expect(isAuthor, true);

      final notAuthor = container.read(isAuthorProvider('otro_user'));
      expect(notAuthor, false);
    });
  });
}