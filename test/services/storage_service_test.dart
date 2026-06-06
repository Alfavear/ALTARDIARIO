import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:altar_diario/data/services/storage_service.dart';

void main() {
  group('StorageService', () {
    late SharedPreferences prefs;
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
    });

    group('fechas completadas', () {
      test('inicia sin fechas completadas', () async {
        final dates = await storage.getCompletedDates();
        expect(dates, isEmpty);
      });

      test('markDateAsCompleted agrega fecha', () async {
        await storage.markDateAsCompleted('2026-06-01');
        final dates = await storage.getCompletedDates();
        expect(dates, ['2026-06-01']);
      });

      test('markDateAsCompleted no duplica fechas', () async {
        await storage.markDateAsCompleted('2026-06-01');
        await storage.markDateAsCompleted('2026-06-01');
        final dates = await storage.getCompletedDates();
        expect(dates, ['2026-06-01']);
      });

      test('unmarkDateAsCompleted elimina fecha', () async {
        await storage.markDateAsCompleted('2026-06-01');
        await storage.unmarkDateAsCompleted('2026-06-01');
        final dates = await storage.getCompletedDates();
        expect(dates, isEmpty);
      });

      test('toggleLectura marca y desmarca', () async {
        await storage.toggleLectura('2026-06-01');
        expect(storage.isDiaCompletado('2026-06-01'), true);

        await storage.toggleLectura('2026-06-01');
        expect(storage.isDiaCompletado('2026-06-01'), false);
      });
    });

    group('racha (streak)', () {
      test('calcularRacha devuelve 0 sin fechas', () {
        expect(storage.calcularRacha([]), 0);
      });

      test('calcularRacha devuelve 1 con solo hoy', () {
        final today = DateTime.now();
        final formatted =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        expect(storage.calcularRacha([formatted]), 1);
      });

      test('calcularRacha cuenta días consecutivos hacia atrás', () {
        final today = DateTime.now();
        final dates = <String>[];
        for (int i = 0; i < 5; i++) {
          final d = today.subtract(Duration(days: i));
          dates.add(
              '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
        }
        expect(storage.calcularRacha(dates), 5);
      });

      test('calcularRacha se rompe con día faltante', () {
        final today = DateTime.now();
        final dates = <String>[
          // hoy y ayer OK, anteayer falta
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}',
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${(today.day - 1).toString().padLeft(2, '0')}',
          // día -3 (salta -2)
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${(today.day - 3).toString().padLeft(2, '0')}',
        ];
        expect(storage.calcularRacha(dates), 2);
      });
    });

    group('plan start date', () {
      test('getPlanStartDate devuelve null sin fecha guardada', () async {
        final date = await storage.getPlanStartDate();
        expect(date, isNull);
      });

      test('setPlanStartDate guarda y recupera fecha', () async {
        final date = DateTime(2026, 1, 1);
        await storage.setPlanStartDate(date);
        final retrieved = await storage.getPlanStartDate();
        expect(retrieved, date);
      });
    });

    group('progreso', () {
      test('getProgreso devuelve 0 sin completadas', () {
        expect(storage.getProgreso([]), 0.0);
      });

      test('getProgreso calcula correctamente', () {
        final completadas = List.generate(73, (i) => '2026-${(i ~/ 28 + 1).toString().padLeft(2, '0')}-${(i % 28 + 1).toString().padLeft(2, '0')}');
        expect(storage.getProgreso(completadas), closeTo(73 / 365, 0.001));
      });

      test('getTotalCompletadas cuenta correctamente', () {
        expect(storage.getTotalCompletadas([]), 0);
        final dates = ['2026-01-01', '2026-01-02'];
        expect(storage.getTotalCompletadas(dates), 2);
      });
    });

    group('máxima racha', () {
      test('getMaxStreak devuelve 0 inicialmente', () {
        expect(storage.getMaxStreak(), 0);
      });
    });

    group('isPlanGenerated', () {
      test('devuelve false inicialmente', () async {
        expect(await storage.isPlanGenerated(), false);
      });

      test('setPlanGenerated guarda estado', () async {
        await storage.setPlanGenerated(true);
        expect(await storage.isPlanGenerated(), true);
      });
    });

    group('getLecturasMes', () {
      test('devuelve lista con días del mes', () {
        // Sin plan cargado, getLecturasMes devuelve "Lectura no disponible"
        final lecturas = storage.getLecturasMes(1);
        expect(lecturas.length, 31);
        expect(lecturas.first.pasajes, 'Lectura no disponible');
        expect(lecturas.first.dia, 1);
      });
    });
  });
}
