import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lectura_dia.dart';

/// Servicio de almacenamiento local para el progreso de lectura.
class StorageService {
  static const String _completedDatesKey = 'completed_dates';
  static const String _maxStreakKey = 'max_streak';

  late SharedPreferences _prefs;
  Map<String, String> _planLectura = {};
  Set<String> _completedDates = {};

  /// Inicializa el servicio cargando las preferencias y el plan de lectura.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadPlan();
    _loadCompletedDates();
  }

  /// Carga el plan de lectura desde el asset JSON.
  Future<void> _loadPlan() async {
    final String jsonString =
        await rootBundle.loadString('assets/plan_lectura.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    _planLectura = data.map((k, v) => MapEntry(k, v.toString()));
  }

  /// Carga las fechas completadas desde SharedPreferences.
  void _loadCompletedDates() {
    final List<String> dates =
        _prefs.getStringList(_completedDatesKey) ?? [];
    _completedDates = dates.toSet();
  }

  /// Obtiene todas las lecturas del plan como lista de LecturaDia.
  List<LecturaDia> getAllLecturas() {
    return _planLectura.entries.map((entry) {
      return LecturaDia(
        fechaClave: entry.key,
        pasajes: entry.value,
        completada: _completedDates.contains(entry.key),
      );
    }).toList()
      ..sort((a, b) => a.fechaClave.compareTo(b.fechaClave));
  }

  /// Obtiene la lectura de un día específico (formato "MM-dd").
  LecturaDia? getLectura(String fechaClave) {
    final pasajes = _planLectura[fechaClave];
    if (pasajes == null) return null;
    return LecturaDia(
      fechaClave: fechaClave,
      pasajes: pasajes,
      completada: _completedDates.contains(fechaClave),
    );
  }

  /// Obtiene las lecturas de un mes específico (1-12).
  List<LecturaDia> getLecturasMes(int mes) {
    final mesStr = mes.toString().padLeft(2, '0');
    return _planLectura.entries
        .where((e) => e.key.startsWith('$mesStr-'))
        .map((e) => LecturaDia(
              fechaClave: e.key,
              pasajes: e.value,
              completada: _completedDates.contains(e.key),
            ))
        .toList()
      ..sort((a, b) => a.fechaClave.compareTo(b.fechaClave));
  }

  /// Marca o desmarca una lectura como completada.
  Future<void> toggleLectura(String fechaClave) async {
    if (_completedDates.contains(fechaClave)) {
      _completedDates.remove(fechaClave);
    } else {
      _completedDates.add(fechaClave);
    }
    await _prefs.setStringList(
        _completedDatesKey, _completedDates.toList());

    // Actualizar racha máxima
    final currentStreak = calcularRacha();
    final maxStreak = getMaxStreak();
    if (currentStreak > maxStreak) {
      await _prefs.setInt(_maxStreakKey, currentStreak);
    }
  }

  /// Verifica si un día específico fue completado.
  bool isDiaCompletado(String fechaClave) {
    return _completedDates.contains(fechaClave);
  }

  /// Calcula la racha actual de días consecutivos leídos
  /// contando hacia atrás desde hoy.
  int calcularRacha() {
    final now = DateTime.now();
    int streak = 0;

    // Empezamos desde hoy y retrocedemos
    for (int i = 0; i <= 365; i++) {
      final date = now.subtract(Duration(days: i));
      final clave =
          '${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (_completedDates.contains(clave)) {
        streak++;
      } else {
        // Si hoy no ha leído pero ayer sí, empezamos la racha desde ayer
        if (i == 0) continue;
        break;
      }
    }
    return streak;
  }

  /// Obtiene la racha máxima registrada.
  int getMaxStreak() {
    return _prefs.getInt(_maxStreakKey) ?? 0;
  }

  /// Obtiene el total de lecturas completadas.
  int getTotalCompletadas() {
    return _completedDates.length;
  }

  /// Obtiene el porcentaje de progreso del plan (0.0 a 1.0).
  double getProgreso() {
    if (_planLectura.isEmpty) return 0.0;
    return _completedDates.length / _planLectura.length;
  }

  /// Obtiene el progreso de un mes específico (0.0 a 1.0).
  double getProgresoMes(int mes) {
    final lecturasMes = getLecturasMes(mes);
    if (lecturasMes.isEmpty) return 0.0;
    final completadas = lecturasMes.where((l) => l.completada).length;
    return completadas / lecturasMes.length;
  }

  /// Obtiene la clave de fecha para hoy en formato "MM-dd".
  String getFechaHoy() {
    final now = DateTime.now();
    return '${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
