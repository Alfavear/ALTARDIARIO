import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/lectura_dia.dart';
import '../models/note.dart';

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
      final String response =
          await rootBundle.loadString('assets/plan_lectura.json');
      final Map<String, dynamic> data = json.decode(response);
      _planData = Map<String, String>.from(data);
    } catch (e) {
      debugPrint('Error crítico cargando plan_lectura.json: $e');
    }
  }

  Future<void> setPlanStartDate(DateTime date) async {
    await _prefs.setString(_keyPlanStartDate, date.toIso8601String());
  }

  Future<DateTime?> getPlanStartDate() async {
    final dateStr = _prefs.getString(_keyPlanStartDate);
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }

  Future<void> markDateAsCompleted(String dateFormatted) async {
    final completed = _prefs.getStringList(_keyCompletedDates) ?? [];
    if (!completed.contains(dateFormatted)) {
      completed.add(dateFormatted);
      await _prefs.setStringList(_keyCompletedDates, completed);
    }
  }

  Future<void> unmarkDateAsCompleted(String dateFormatted) async {
    final completed = _prefs.getStringList(_keyCompletedDates) ?? [];
    if (completed.contains(dateFormatted)) {
      completed.remove(dateFormatted);
      await _prefs.setStringList(_keyCompletedDates, completed);
    }
  }

  Future<List<String>> getCompletedDates() async {
    return _prefs.getStringList(_keyCompletedDates) ?? [];
  }

  List<String> getCompletedDatesSync() {
    return _prefs.getStringList(_keyCompletedDates) ?? [];
  }

  Future<void> toggleLectura(String dateFormatted) async {
    final completed = getCompletedDatesSync();
    if (completed.contains(dateFormatted)) {
      await unmarkDateAsCompleted(dateFormatted);
    } else {
      await markDateAsCompleted(dateFormatted);
      await _updateMaxStreak();
    }
  }

  bool isDiaCompletado(String dateFormatted) {
    return getCompletedDatesSync().contains(dateFormatted);
  }

  int calcularRacha([List<String>? completedDates]) {
    final dates = completedDates ?? getCompletedDatesSync();
    if (dates.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime.now();

    final todayStr = _formatDate(checkDate);
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

  List<LecturaDia> getLecturasMes(int mes) {
    final year = DateTime.now().year;
    final daysInMonth = DateTime(year, mes + 1, 0).day;
    final List<LecturaDia> lecturas = [];

    for (int i = 0; i < daysInMonth; i++) {
      final dayNum = i + 1;
      final monthStr = mes.toString().padLeft(2, '0');
      final dayStr = dayNum.toString().padLeft(2, '0');
      final dateKey = '$monthStr-$dayStr';
      final dateClave = '$year-$monthStr-$dayStr';

      lecturas.add(LecturaDia(
        dia: dayNum,
        pasajes: _planData[dateKey] ?? 'Lectura no disponible',
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

  static const String _keyNotifHour = 'notification_hour';
  static const String _keyNotifMin = 'notification_minute';

  int getNotificationHour() => _prefs.getInt(_keyNotifHour) ?? 20;
  int getNotificationMinute() => _prefs.getInt(_keyNotifMin) ?? 0;

  Future<void> setNotificationTime(int hour, int minute) async {
    await _prefs.setInt(_keyNotifHour, hour);
    await _prefs.setInt(_keyNotifMin, minute);
  }

  // ── Notas ─────────────────────────────────────────────────────

  static const String _keyNotes = 'user_notes';

  Future<List<Note>> getNotes() async {
    final json = _prefs.getString(_keyNotes);
    if (json == null || json.isEmpty) return [];
    return Note.decodeList(json);
  }

  Future<void> saveNote(Note note) async {
    final notes = await getNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _prefs.setString(_keyNotes, Note.encodeList(notes));
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((n) => n.id == id);
    await _prefs.setString(_keyNotes, Note.encodeList(notes));
  }
}
