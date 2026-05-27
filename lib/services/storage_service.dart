import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../data/models/lectura_dia.dart';

/// Servicio para la persistencia local de datos de la aplicación.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyPlanStartDate = 'plan_start_date';
  static const String _keyCompletedDates = 'completed_dates';
  static const String _keyIsPlanGenerated = 'is_plan_generated';
  static const String _keyMaxStreak = 'max_streak';

  Map<String, String> _planData = {};

  /// Carga el plan de lectura desde el archivo de assets.
  Future<void> loadPlan() async {
    try {
      final String response = await rootBundle.loadString('assets/plan_lectura.json');
      final Map<String, dynamic> data = json.decode(response);
      _planData = Map<String, String>.from(data);
    } catch (e) {
      debugPrint('Error crítico cargando plan_lectura.json: $e');
    }
  }

  Future<void> setPlanStartDate(DateTime date) async {
    await _prefs.setString(_keyPlanStartDate, date.toIso8601String());
  }

  /// Obtiene la fecha de inicio del plan.
  Future<DateTime?> getPlanStartDate() async {
    final dateStr = _prefs.getString(_keyPlanStartDate);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  /// Marca una fecha específica (formato yyyy-MM-dd) como completada.
  Future<void> markDateAsCompleted(String dateFormatted) async {
    final completed = _prefs.getStringList(_keyCompletedDates) ?? [];
    if (!completed.contains(dateFormatted)) {
      completed.add(dateFormatted);
      await _prefs.setStringList(_keyCompletedDates, completed);
    }
  }

  /// Desmarca una fecha como completada.
  Future<void> unmarkDateAsCompleted(String dateFormatted) async {
    final completed = _prefs.getStringList(_keyCompletedDates) ?? [];
    if (completed.contains(dateFormatted)) {
      completed.remove(dateFormatted);
      await _prefs.setStringList(_keyCompletedDates, completed);
    }
  }

  /// Obtiene el listado de todas las fechas completadas.
  Future<List<String>> getCompletedDates() async {
    return _prefs.getStringList(_keyCompletedDates) ?? [];
  }

  /// Obtiene el listado de todas las fechas completadas de forma síncrona.
  List<String> getCompletedDatesSync() {
    return _prefs.getStringList(_keyCompletedDates) ?? [];
  }

  /// Cambia el estado de una lectura (completado/pendiente).
  Future<void> toggleLectura(String dateFormatted) async {
    final completed = getCompletedDatesSync();
    if (completed.contains(dateFormatted)) {
      await unmarkDateAsCompleted(dateFormatted);
    } else {
      await markDateAsCompleted(dateFormatted);
      await _updateMaxStreak();
    }
  }

  /// Verifica si una fecha está completada (Lógica simplificada para persistencia).
  bool isDiaCompletado(String dateFormatted) {
    return getCompletedDatesSync().contains(dateFormatted);
  }

  /// Calcula la racha actual de días consecutivos.
  int calcularRacha([List<String>? completedDates]) {
    final dates = completedDates ?? getCompletedDatesSync();
    if (dates.isEmpty) return 0;
    
    int streak = 0;
    DateTime checkDate = DateTime.now();
    
    // Si hoy no se ha leído, empezamos a contar desde ayer
    String todayStr = _formatDate(checkDate);
    if (!dates.contains(todayStr)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (dates.contains(_formatDate(checkDate))) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    return streak;
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Obtiene las lecturas de un mes desde el plan cargado.
  List<LecturaDia> getLecturasMes(int mes) {
    final year = DateTime.now().year;
    final daysInMonth = DateTime(year, mes + 1, 0).day;
    final List<LecturaDia> lecturas = [];

    for (int i = 0; i < daysInMonth; i++) {
      final dayNum = i + 1;
      final monthStr = mes.toString().padLeft(2, '0');
      final dayStr = dayNum.toString().padLeft(2, '0');
      final dateKey = "$monthStr-$dayStr";
      final dateClave = "$year-$monthStr-$dayStr";

      lecturas.add(LecturaDia(
        dia: dayNum,
        pasajes: _planData[dateKey] ?? "Lectura no disponible",
        fechaClave: dateClave,
        completada: isDiaCompletado(dateClave),
      ));
    }
    return lecturas;
  }

  double getProgresoMes(int mes) {
    final lecturas = getLecturasMes(mes);
    if (lecturas.isEmpty) return 0.0;
    final completadas = lecturas.where((l) => l.completada).length;
    return completadas / lecturas.length;
  }

  int getMaxStreak() {
    return _prefs.getInt(_keyMaxStreak) ?? 0;
  }

  int getTotalCompletadas([List<String>? completedDates]) {
    final dates = completedDates ?? getCompletedDatesSync();
    return dates.length;
  }

  double getProgreso([List<String>? completedDates]) {
    final dates = completedDates ?? getCompletedDatesSync();
    if (dates.isEmpty) return 0.0;
    return dates.length / 365;
  }

  /// Verifica si el plan ya ha sido generado/inicializado.
  Future<bool> isPlanGenerated() async {
    return _prefs.getBool(_keyIsPlanGenerated) ?? false;
  }

  Future<void> setPlanGenerated(bool value) async {
    await _prefs.setBool(_keyIsPlanGenerated, value);
  }

  Future<void> _updateMaxStreak() async {
    final completedDates = await getCompletedDates();
    final current = calcularRacha(completedDates);
    final max = _prefs.getInt(_keyMaxStreak) ?? 0;
    if (current > max) {
      await _prefs.setInt(_keyMaxStreak, current);
    }
  }
}